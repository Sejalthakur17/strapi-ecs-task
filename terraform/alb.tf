########################################
# ALB Security Group
########################################

resource "aws_security_group" "alb_sg" {
  name        = "sejal-ecs-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################
# Application Load Balancer
########################################

resource "aws_lb" "ecs_alb" {
  name               = "sejal-ecs-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb_sg.id]

  enable_deletion_protection = false
}

########################################
# Target Group
########################################

resource "aws_lb_target_group" "ecs_tg" {
  name        = "sejal-ecs-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "ip"

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

########################################
# Listener
########################################

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

########################################
# Output ALB DNS
########################################

output "alb_dns_name" {
  description = "Public URL of the ALB"
  value       = aws_lb.ecs_alb.dns_name
}