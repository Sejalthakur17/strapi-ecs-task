resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/strapi"
  retention_in_days = 7

  tags = {
    Name = "strapi-log-group"
  }
}
