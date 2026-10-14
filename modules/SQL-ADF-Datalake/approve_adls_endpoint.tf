
resource "terraform_data" "approve_adls_endpoint" {
  triggers_replace = [
    azurerm_data_factory_managed_private_endpoint.adls_dfs.id,
    azurerm_storage_account.adls.id
  ]

  depends_on = [
    azurerm_data_factory_managed_private_endpoint.adls_dfs
  ]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]

    environment = {
      STORAGE_ACCOUNT_ID = azurerm_storage_account.adls.id
      MPE_NAME           = azurerm_data_factory_managed_private_endpoint.adls_dfs.name
      DATA_FACTORY_NAME  = azurerm_data_factory.adf.name
    }

    command = <<-EOT
      $ErrorActionPreference = "Stop"

      $storageId = $env:STORAGE_ACCOUNT_ID
      $mpe       = $env:MPE_NAME
      $adfName   = $env:DATA_FACTORY_NAME

      if (!$storageId -or !$mpe -or !$adfName) {
        throw "Required Terraform resource IDs or names are missing."
      }

      Write-Output "Checking Azure CLI login..."

      az account show --output none

      if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI is not logged in. Run az login and retry."
      }

      Write-Output "Getting storage private endpoint connections..."

      $url = "https://management.azure.com$storageId/privateEndpointConnections?api-version=2025-06-01"

      $response = az rest --method get --url $url --output json

      if ($LASTEXITCODE -ne 0) {
        throw "Unable to list private endpoint connections. Check Azure permissions."
      }

      $connections = ($response | ConvertFrom-Json).value

      $expectedSuffix = "$adfName.$mpe"

      $matches = @(
        $connections | Where-Object {
          $endpointId = $_.properties.privateEndpoint.id

          $endpointId -and $endpointId.EndsWith(
            $expectedSuffix,
            [System.StringComparison]::OrdinalIgnoreCase
          )
        }
      )

      if ($matches.Count -ne 1) {
        Write-Output "Matching connection details:"
        $connections | ForEach-Object {
          Write-Output ("Connection: " + $_.name)
          Write-Output ("Endpoint ID: " + $_.properties.privateEndpoint.id)
          Write-Output ("Status: " + $_.properties.privateLinkServiceConnectionState.status)
        }

        throw "Expected exactly one connection ending in $expectedSuffix; found $($matches.Count)."
      }

      $connection = $matches[0]
      $status = $connection.properties.privateLinkServiceConnectionState.status

      if ($status -eq "Approved") {
        Write-Output "Connection is already approved."
      }
      elseif ($status -eq "Pending") {
        Write-Output "Pending connection found. Submitting approval..."

        $body = @{
          properties = @{
            privateLinkServiceConnectionState = @{
              status      = "Approved"
              description = "Approved by Terraform for ADF endpoint $mpe"
            }
          }
        } | ConvertTo-Json -Depth 10 -Compress

        $bodyFile = Join-Path $env:TEMP "approve-adls-private-endpoint.json"

        try {
          Set-Content -Path $bodyFile -Value $body -Encoding utf8

          $approveUrl = "https://management.azure.com$($connection.id)?api-version=2025-06-01"

          az rest `
            --method put `
            --url $approveUrl `
            --headers "Content-Type=application/json" `
            --body "@$bodyFile" `
            --output none

          if ($LASTEXITCODE -ne 0) {
            throw "Approval failed. Check Azure permissions and the API response."
          }

          Write-Output "Approval request submitted successfully."
        }
        finally {
          Remove-Item $bodyFile -ErrorAction SilentlyContinue
        }

        Write-Output "Verifying approval status..."

        Start-Sleep -Seconds 3

        $verifyResponse = az rest --method get --url $url --output json

        if ($LASTEXITCODE -ne 0) {
          throw "Could not verify the approval status."
        }

        $verifiedConnections = ($verifyResponse | ConvertFrom-Json).value

        $verified = @(
          $verifiedConnections | Where-Object {
            $_.properties.privateEndpoint.id -and
            $_.properties.privateEndpoint.id.EndsWith(
              $expectedSuffix,
              [System.StringComparison]::OrdinalIgnoreCase
            )
          }
        )

        if (
          $verified.Count -ne 1 -or
          $verified[0].properties.privateLinkServiceConnectionState.status -ne "Approved"
        ) {
          throw "Approval is not yet confirmed. Check the connection status in Azure Portal."
        }

        Write-Output "SUCCESS: Private endpoint connection is approved."
      }
      else {
        throw "Unexpected connection status: $status. Check the connection in Azure Portal."
      }
    EOT
  }
}
