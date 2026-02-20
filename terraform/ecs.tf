############################
# ECS CLUSTER
############################

resource "aws_ecs_cluster" "sejal_cluster" {
  name = "sejal-fargate-cluster"
}

############################
# TASK DEFINITION (FARGATE)
############################

resource "aws_ecs_task_definition" "sejal_task" {
  family                   = "sejal-fargate-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"
  task_role_arn      = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"

  container_definitions = jsonencode([
    {
      name      = "sejal-container"
      image     = var.image_url
      essential = true

      portMappings = [{
        containerPort = 1337
        protocol      = "tcp"
      }]

      logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.strapi_logs.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }

      environment = [
         {
            name  = "DATABASE_CLIENT"
            value = "postgres"
             },
  {
    name  = "DATABASE_HOST"
    value = aws_db_instance.sejal_db.address
  },
  {
    name  = "DATABASE_PORT"
    value = "5432"
  },
  {
    name  = "DATABASE_NAME"
    value = "postgres"
  },
  {
    name  = "DATABASE_USERNAME"
    value = var.db_username
  },
  {
    name  = "DATABASE_PASSWORD"
    value = var.db_password
  },
  {
  name  = "DATABASE_SSL"
  value = "true"
},
  {
    name  = "APP_KEYS"
    value = "key1,key2,key3,key4"
  },
  {
    name  = "API_TOKEN_SALT"
    value = "randomsalt123"
  },
  {
    name  = "ADMIN_JWT_SECRET"
    value = "adminjwtsecret123"
  },
  {
    name  = "JWT_SECRET"
    value = "jwtsecret123"
  },
  {
    name  = "HOST"
    value = "0.0.0.0"
  },
  {
    name  = "PORT"
    value = "1337"
  },
  {
    name  = "NODE_ENV"
    value = "production"
  }
]
    }
  ])
}

############################
# ECS SERVICE (FARGATE)
############################
resource "aws_security_group" "ecs_sg" {
  name        = "sejal-ecs-service-sg"
  description = "Allow traffic from ALB to ECS"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_ecs_service" "sejal_service" {
  name            = "sejal-service"
  cluster         = aws_ecs_cluster.sejal_cluster.id
  task_definition = aws_ecs_task_definition.sejal_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  load_balancer {
  target_group_arn = aws_lb_target_group.ecs_tg.arn
  container_name   = "sejal-container"  
  container_port   = 1337
}

  network_configuration {
  subnets          = data.aws_subnets.default.ids
  security_groups  = [aws_security_group.ecs_sg.id]
  assign_public_ip = false
}
  depends_on = [
    aws_lb_listener.ecs_listener
  ]
}
