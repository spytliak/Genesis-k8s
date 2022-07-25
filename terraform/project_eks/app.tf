resource "null_resource" "K8S_Deploy_APP" {
  count = var.deploy_app ? 1 : 0
  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
  triggers = {}
  provisioner "local-exec" {
    when        = create
    on_failure  = continue
    command     = <<-EOT
          # Deploy APP
          kubectl apply  -f <(echo $MANIFEST_MYSQL | base64 -d) --kubeconfig <(echo $KUBECONFIG_B64 | base64 -d)
          kubectl apply  -f <(echo $MANIFEST_FLASK | base64 -d) --kubeconfig <(echo $KUBECONFIG_B64 | base64 -d)

          # Check pods in flask-app namespace
          kubectl get po -A --kubeconfig <(echo $KUBECONFIG_B64 | base64 -d)
        EOT
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG_B64 = nonsensitive(base64encode(local.kubeconfig))
      MANIFEST_FLASK = base64encode(templatefile("../../deploy/flask-app.yaml",{}))
      MANIFEST_MYSQL = base64encode(templatefile("../../deploy/mysql.yaml",
        {
          "MYSQL_PASSWORD" = var.MYSQL_PASSWORD
          "MYSQL_ROOT_PASSWORD" = var.MYSQL_ROOT_PASSWORD
        }
        )
      )
    }
  }
}