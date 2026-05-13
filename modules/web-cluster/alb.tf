# Application Load Balancer (ALB)
resource "aws_lb" "app_alb" {
  name               = "${var.environment}-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.alb_subnet_ids # public subnets
}

# Target Group for ALB
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.environment}-target-group"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# ALB Listener to forward traffic to the Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = var.server_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}