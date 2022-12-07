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

resource "aws_cloudwatch_log_group" "aws_ecs_log_group" {
  name              = "/aws/ecs/ascan_devops"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecr_repository" "ascan_devops_repo" {
  name = "ascan-devops-repo" # Naming my repository
}

resource "aws_ecs_cluster" "ascan_devops_cluster" {
  name = "ascan_devops_cluster" # Naming the cluster
}

resource "aws_ecs_service" "ascan_devops_service" {
  name            = "ascan-devops-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.ascan_devops_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.ascan_devops.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers we want deployed to 3

    load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.ascan_devops.family}"
    container_port   = 8080 # Specifying the container port
  }
    network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    security_groups  = ["${aws_security_group.service_security_group.id}"]
    assign_public_ip = true # Providing our containers with public IPs
  }
}


resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0 
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" 
  health_check {
    matcher = "200,301,302"
    path = "/alive"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}" 
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }
}


resource "aws_alb" "application_load_balancer" {
  name               = "test-lb-tf" 
  load_balancer_type = "application"
  subnets = [ 
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
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
      "logConfiguration":{
        "logDriver": "awslogs",
        "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.aws_ecs_log_group.name}",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "ecs"
            }
      },
      "memory": 512,
      "cpu": 256
    }

  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"    
  memory                   = 512        
  cpu                      = 256         
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"

}

resource "aws_default_vpc" "default_vpc" {
}
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}
resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}
resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c"
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

