
# Create the Employee table and insert sample records.

resource "terraform_data" "create_employee_table" {
  triggers_replace = [
    azurerm_mssql_database.db.id
  ]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]

    environment = {
      SQL_SERVER   = azurerm_mssql_server.sql.fully_qualified_domain_name
      SQL_DATABASE = azurerm_mssql_database.db.name
      SQL_USERNAME = var.sql_admin_username
      SQL_PASSWORD = var.sql_admin_password
    }

    command = <<-EOT
      $ErrorActionPreference = "Stop"

      $server   = $env:SQL_SERVER
      $database = $env:SQL_DATABASE
      $username = $env:SQL_USERNAME
      $password = $env:SQL_PASSWORD

      $sqlFile = Join-Path $env:TEMP "create_employee.sql"

      $sql = @'
      IF OBJECT_ID('dbo.Employee', 'U') IS NULL
      BEGIN
          CREATE TABLE dbo.Employee (
              EmployeeID INT PRIMARY KEY,
              FirstName VARCHAR(50) NOT NULL,
              LastName VARCHAR(50) NOT NULL,
              Department VARCHAR(50),
              City VARCHAR(50),
              Salary DECIMAL(10,2),
              JoiningDate DATE
          );
      END;

      IF NOT EXISTS (SELECT 1 FROM dbo.Employee)
      BEGIN
          INSERT INTO dbo.Employee
              (EmployeeID, FirstName, LastName, Department, City, Salary, JoiningDate)
          VALUES
              (101, 'Rahul', 'Sharma', 'IT', 'Mumbai', 65000, '2023-01-15'),
              (102, 'Priya', 'Patil', 'HR', 'Pune', 55000, '2022-06-10'),
              (103, 'Amit', 'Khan', 'Finance', 'Delhi', 60000, '2021-09-20'),
              (104, 'Sneha', 'Shaikh', 'IT', 'Pune', 72000, '2024-02-01'),
              (105, 'Vikas', 'Desai', 'Sales', 'Bengaluru', 50000, '2023-11-12');
      END;

      SELECT * FROM dbo.Employee ORDER BY EmployeeID;
      '@

      try {
          Set-Content -Path $sqlFile -Value $sql -Encoding utf8

          & sqlcmd -S "tcp:$server,1433" -d $database -U $username -P $password -N -b -i $sqlFile

          if ($LASTEXITCODE -ne 0) {
              throw "SQL execution failed with exit code $LASTEXITCODE."
          }
      }
      finally {
          Remove-Item $sqlFile -Force -ErrorAction SilentlyContinue
      }
    EOT
  }

  depends_on = [
    azurerm_mssql_firewall_rule.azure_services,
    azurerm_mssql_firewall_rule.client_ip
  ]
}
