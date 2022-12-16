# Overview

Create the infrastructure to deploy a simple website (helloworld!) with a complete CI CD deploy to ECR and ECS services from Amazon AWS

## Table Of Contantes
* [How to Use](#how-to-use)


## How to use

### Requirements for run this project

* [Docker](https://docs.docker.com/engine/install/)
* [Git](https://git-scm.com/)
* [Terraform](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)


### Setting up the Cloud environment

#### Export your AWS Credentials

```sh
$ export AWS_ACCESS_KEY_ID=(your_id)
$ export AWS_SECRET_ACCESS_KEY=(your_secret)
```

#### Applying terraform files

```sh
$ cd terraform
$ terraform init
$ terraform apply
```

#### Running the CI CD Pipeline

* Make sure the following secrets are set at Settings>Secrets
```
AWS_ACCESS_KEY_ID=(your_id)
AWS_SECRET_ACCESS_KEY=(your_secret)
```
* Then, It's possible to run this pipeline manually, or just commit/PR to main

#### Useful Information
The infrastructure code sets up a load balancer, make sure when you to check the DNS name using

```sh
$ terraform state show aws_alb.application_load_balancer
```
then, your application should render after the deployment has finished