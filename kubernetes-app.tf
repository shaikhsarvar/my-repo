
# =========================================================
# CUSTOM NGINX WELCOME PAGE
# =========================================================

resource "kubernetes_config_map_v1" "my_app_html" {

  metadata {
    name = "my-app-html"
  }

  data = {
    "index.html" = <<-HTML
      <!DOCTYPE html>
      <html>

      <head>
        <meta charset="UTF-8">
        <title>Shaikh Sarvar - AKS</title>

        <style>

          body {
            margin: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #0f172a, #2563eb);
            color: white;
            text-align: center;
            overflow: hidden;
          }

          .box {
            padding: 50px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.12);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.4);
            animation: float 3s ease-in-out infinite;
          }

          h1 {
            font-size: 50px;
            margin-bottom: 20px;
            animation: glow 2s infinite alternate;
          }

          h2 {
            font-size: 30px;
          }

          p {
            font-size: 20px;
            margin: 12px;
          }

          .success {
            margin-top: 25px;
            padding: 12px 25px;
            border-radius: 30px;
            background: rgba(34, 197, 94, 0.8);
            display: inline-block;
            font-size: 18px;
            animation: pulse 2s infinite;
          }

          @keyframes float {

            0%, 100% {
              transform: translateY(0);
            }

            50% {
              transform: translateY(-15px);
            }

          }

          @keyframes glow {

            from {
              text-shadow: 0 0 10px #ffffff;
            }

            to {
              text-shadow: 0 0 30px #60a5fa;
            }

          }

          @keyframes pulse {

            0% {
              transform: scale(1);
            }

            50% {
              transform: scale(1.08);
            }

            100% {
              transform: scale(1);
            }

          }

        </style>

      </head>

      <body>

        <div class="box">

          <h1>🚀 Welcome The World OF Automation!</h1>

          <h2>👨‍💻 Shaikh Sarvar</h2>

          <p>Terraform Deployed AKS & Application</p>

          <p>☁️ Azure Kubernetes Service (AKS)</p>

          <p>🐳 Application</p>

          <p>⚙️ Infrastructure as Code with Terraform</p>

          <div class="success">
            ✅ Hi Shaikh Sarvar AKS & Application Successfully Deployed
          </div>

        </div>

      </body>

      </html>
    HTML
  }
}


# =========================================================
# APPLICATION DEPLOYMENT
# =========================================================

resource "kubernetes_deployment_v1" "my_app" {

  metadata {
    name = "my-app"
  }

  spec {

    replicas = 2

    selector {
      match_labels = {
        app = "my-app"
      }
    }

    template {

      metadata {
        labels = {
          app = "my-app"
        }
      }

      spec {

        # -------------------------------------------------
        # RUN APPLICATION ONLY ON USER NODE POOL
        # -------------------------------------------------

        node_selector = {
          nodepool = "user"
        }

        container {

          name  = "my-app"
          image = "nginx:1.27"

          port {
            container_port = 80
          }

          # -------------------------------------------------
          # MOUNT CUSTOM HTML PAGE
          # -------------------------------------------------

          volume_mount {

            name       = "html"
            mount_path = "/usr/share/nginx/html/index.html"
            sub_path   = "index.html"
          }

          # -------------------------------------------------
          # RESOURCE REQUESTS / LIMITS
          # -------------------------------------------------

          resources {

            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          # -------------------------------------------------
          # READINESS PROBE
          # -------------------------------------------------

          readiness_probe {

            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }

          # -------------------------------------------------
          # LIVENESS PROBE
          # -------------------------------------------------

          liveness_probe {

            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 15
            period_seconds        = 20
          }
        }

        # -------------------------------------------------
        # CONFIGMAP VOLUME
        # -------------------------------------------------

        volume {

          name = "html"

          config_map {
            name = kubernetes_config_map_v1.my_app_html.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    module.aks_dev
  ]
}


# =========================================================
# INTERNAL AZURE LOAD BALANCER SERVICE
# =========================================================

#resource "kubernetes_service_v1" "my_app" {

#metadata {

# name = "my-app"

#annotations = {

# -------------------------------------------------
# CREATE INTERNAL AZURE LOAD BALANCER
# -------------------------------------------------

# "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"

# -------------------------------------------------
# INTERNAL LB SUBNET
# -------------------------------------------------

#"service.beta.kubernetes.io/azure-load-balancer-internal-subnet" = "aks-subnet"

# LB IP

#"service.beta.kubernetes.io/azure-load-balancer-ipv4" = "10.1.2.50"

# -------------------------------------------------
# LOAD BALANCER ONLY FOR USER NODE POOL
# -------------------------------------------------

# "service.beta.kubernetes.io/azure-load-balancer-node-selector" = "nodepool=user"
#}
# }

# spec {

# selector = {
#   app = "my-app"
# }

# port {

#  port        = 80
# target_port = 80
#}

# -------------------------------------------------
# INTERNAL LOAD BALANCER
# -------------------------------------------------

#type = "LoadBalancer"

# -------------------------------------------------
# KEEP TRAFFIC ON NODES WITH LOCAL PODS
# -------------------------------------------------

#external_traffic_policy = "Local"
#}

#depends_on = [
#  kubernetes_deployment_v1.my_app
# ]
#}