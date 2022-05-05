resource "aws_lb_target_group" "app" {
  name     = "${var.COMPONENT}-${var.ENV}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.VPC_ID
}

resource "aws_lb_target_group_attachment" "instance-attach" {
  count            = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = element(local.ALL_INSTANCE_IDS, count.index)
  port             = 8080
}

resource "aws_lb_listener_rule" "app_rule" {
  listener_arn = data.terraform_remote_state.alb.outputs.PRIVATE_LISTENER_ARN
  priority     = random_integer.lb-rule_priority.result

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    host_header {
      values = ["${var.COMPONENT}-${var.ENV}.${data.terraform_remote_state.vpc.outputs.HOSTEDZONE_PRIVATE_ZONE}"]
    }
  }
}

resource "random_integer" "lb-rule_priority" {
  min = 100
  max = 500
}

resource "aws_lb_listener" "public_lb_listener" {
  count             = var.LB_TYPE == "public" ? 1 : 0
  load_balancer_arn = data.terraform_remote_state.alb.outputs.PUBLIC_ALB_ARN
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

