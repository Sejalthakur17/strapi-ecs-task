############################
# ECS CLUSTER
############################

resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-ec2-cluster"
}

############################
# ECS OPTIMIZED AMI
############################

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

############################
# LAUNCH TEMPLATE
############################

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-template-"
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = "ecsInstanceProfile"
  }

  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=strapi-ec2-cluster >> /etc/ecs/ecs.config
EOF
  )
}


############################
# AUTO SCALING GROUP
############################

resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.public_subnet.id]

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-instance"
    propagate_at_launch = true
  }
}

############################
# TASK DEFINITION
############################

resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-ec2-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  task_role_arn      = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"
  execution_role_arn = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = var.image_url
      cpu       = 256
      memory    = 512
      essential = true

      portMappings = [{
        containerPort = 1337
        hostPort      = 1337
      }]

      environment = [
        {
          name  = "DATABASE_HOST"
          value = aws_db_instance.strapi_db.address
        },
        {
          name  = "DATABASE_PORT"
          value = "5432"
        },
        {
          name  = "DATABASE_USERNAME"
          value = var.db_username
        },
        {
          name  = "DATABASE_PASSWORD"
          value = var.db_password
        }
      ]
    }
  ])
}

############################
# ECS SERVICE
############################

resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  depends_on = [aws_autoscaling_group.ecs_asg]
}

