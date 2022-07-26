# Genesis-k8s
The repository is for Genesis DevOps School. 

[![EKS](https://github.com/spytliak/Genesis-k8s/actions/workflows/main.yml/badge.svg)](https://github.com/spytliak/Genesis-k8s/actions/workflows/main.yml)
[![Terraform Destroy](https://github.com/spytliak/Genesis-k8s/actions/workflows/destroy.yml/badge.svg)](https://github.com/spytliak/Genesis-k8s/actions/workflows/destroy.yml)

### Description
The repo is for creating AWS EKS and deploy the RESTful API application by Terraform.  
NOTE:
 * The variable **deploy_app** is for creating APP (false is by default).
 * The variables **MYSQL_PASSWORD** and **MYSQL_ROOT_PASSWORD** is for MYSQL manifest.

### Terraform

The project is in [project_eks](/terraform/project_eks/)  

* [eks.tf](/terraform/project_eks/eks.tf)                                       - create AWS EKS by blueprint module [Amazon EKS Blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints)
* [eks.auto.tfvars](/terraform/project_eks/eks.auto.tfvars)                     - the overridden project variables  
* [app.tf](/terraform/project_eks/app.tf)                                       - deploy APP by provisioner
* [locals.tf](/terraform/project_eks/locals.tf)                                 - all locals of project
* [backend.tf](/terraform/project_eks/backend.tf)                               - the backend file (s3)
* [data.tf](/terraform/project_eks/data.tf)                                     - all data of project
* [outputs.tf](/terraform/project_eks/outputs.tf)                               - all outputs 
* [provider.tf](/terraform/project_eks/provider.tf)                             - the provider file
* [variables.tf](/terraform/project_eks/variables.tf)                           - all default variables
* [min-iam-policy.json](/terraform/project_eks/min-iam-policy.json)             - IAM policy

#### Directory tree - Terraform
```bash
└── project_eks
  ├── app.tf
  ├── backend.tf
  ├── data.tf
  ├── eks.auto.tfvars
  ├── eks.tf
  ├── locals.tf
  ├── outputs.tf
  ├── provider.tf
  ├── variables.tf
  └── min-iam-policy.json
```

#### Manifests

The Manifests for APP are in [deploy](/deploy/)  
* [mysql.yaml](/deploy/mysql.yaml)               - deploy mysql: Namespace, Secret, ConfigMap, StatefulSet, Service
* [flask-app.yaml](/deploy/flask-app.yaml)       - deploy flask: ConfigMap, Deployment, Service, Ingress
