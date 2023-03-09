# Demo Alibaba Workshop
Date: 10-03-2023

# Target
- Quickly spin up infrastructure for a MVP node js application 
- Setup CICD to automate the deployment from github to ACK

# Folder structure
``` bash
├── Dockerfile              
├── Makefile                # shorthand commands
├── README.md
├── index.js
├── .github                 # Github action workflow
└── terraform               # IaC code
    ├── cr.tf
    ├── main.tf
    ├── provider.tf
    ├── terraform.tfvars
    └── variables.tf
```

# Instruction

1. Create a RAM user and download the access key. For this demo, we can use `AdministratorAccess`

2. Export credential env to avoid hard code to the terraform code. In this demo, we use ap-southeast-1 (Singapore) as the main region to provision our resources.
```bash
export ALICLOUD_ACCESS_KEY=YOUR_KEY
export ALICLOUD_SECRET_KEY=YOUR_SECRET
export ALICLOUD_REGION=ap-southeast-1
```

3. Clone the code to your folder.
```bash
git clone https://github.com/owl-king/demo-workshop-10032023
```

4. Provision our infrastructure by terraform. You can find the installation instruction in the [link](https://developer.hashicorp.com/terraform/downloads)
```
cd demo-workshop-10032023/terraform
terraform init

# Check the current setup. Modify it if you need to change some configs
terraform plan # See what changes are going to apply to our infrastructure
terraform apply 
# around 7m to create a k8s cluster
# 1-2m to creata a node pool
```

5. Authenticate to k8s cluster
Simple way: 
- Open alibaba console => Container service => Select our cluster hello-mvp.
- Select Connection Information tab => Generate Temporary kubeconfig
- Create config file at ~/.kube/config and paste the content from temporary kubeconfig

Verify  the connection by `kubectl cluster-info`

6. Login to Docker registry

- Obtain credential by visiting [registry-credential](https://cr.console.aliyun.com/ap-southeast-1/instance/credentials?spm=5176.8351553.0.0.699ab212fw2pMO)
- Login from commandline
```
sudo docker login --username=YOUR_USER registry-intl.ap-southeast-1.aliyuncs.com
```

7. Build and push the image
```bash
# Get short commit sha
TAG=`git rev-parse --short HEAD`
IMAGE="registry-intl.ap-southeast-1.aliyuncs.com/hello-mvp/hello-nodejs"

# For m1 mac
make build-image-m1 IMAGE=$IMAGE TAG=$TAG

# For intel
make build-image IMAGE=$IMAGE TAG=$TAG

# Push image

make push-image IMAGE=$IMAGE TAG=$TAG
```

8. Make our service online

```bash
TAG=`git rev-parse --short HEAD`
IMAGE="registry-intl.ap-southeast-1.aliyuncs.com/hello-mvp/hello-nodejs"
DEPLOYMENT_NAME=hello
SERVICE_NAME=hello

make create-deployment DEPLOYMENT_NAME=$DEPLOYMENT_NAME IMAGE=$IMAGE TAG=$TAG
make create-service SERVICE_NAME=$SERVICE_NAME


# See all the resources we have created
kubectl get all

# Watch the pod status
kubectl get pod -w

# Check the service status 
kubectl get svc $SERVICE_NAME
```

9. Setup our cicd pipeline
With the current workflow, it will automatically triggered whenever the code is deployed to master.
Current workflow has several steps:
 - calculate the short sha
 - login to docker registry
 - build and push the image
 - grab the ack credential
 - update the deployment

Before that, we need to add variables to github repository configs.

Secrets:
 - ACCESS_KEY
 - CLUSTER_ID
 - DOCKERHUB_REGISTRY
 - DOCKERHUB_TOKEN
 - DOCKERHUB_USERNAME
 - PRIVATE_KEY

Variables:
 - CONTAINER_NAME
 - DEPLOYMENT_NAME
 - IMAGE
