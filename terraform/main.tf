terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
  }

}
provider "aws" {
    region="us-east-1"
}



resource "aws_ecr_repository" "ascan_devops_repo" {
  name = "ascan-devops-repo" # Naming my repository
}

resource "aws_ecs_cluster" "ascan_devops_cluster" {
  name = "ascan_devops_cluster" # Naming the cluster
}

resource "aws_security_group" "web-node" {
  vpc_id = aws_default_vpc.default_vpc.id
  name = "Security group"
  description = "Web Security Group"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_service" "ascan_devops_service" {
  name            = "ascan-devops-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.ascan_devops_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.ascan_devops.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1 # Setting the number of containers we want deployed to 3
    network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}"]
    security_groups = [ "${aws_security_group.web-node.id}" ]
    assign_public_ip = true # Providing our containers with public IPs
  }
}

resource "aws_ecs_task_definition" "ascan_devops" {
  family                   = "ascan_devops" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "ascan_devops",
      "image": "${aws_ecr_repository.ascan_devops_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "memory": 512,
      "cpu": 256,
        "logConfiguration": {
        "logDriver": "awslogs",
              "options": {
                  "awslogs-group": "firelens-container",
                  "awslogs-region": "us-east-1",
                  "awslogs-create-group": "true",
                  "awslogs-stream-prefix": "firelens"
                }   
        }
    }

  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"

}

resource "aws_default_vpc" "default_vpc" {
}
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}