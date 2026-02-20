resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "sejal-ecs-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.sejal_cluster.name, "ServiceName", aws_ecs_service.sejal_service.name ],
            [ ".", "MemoryUtilization", ".", ".", ".", "." ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ECS CPU & Memory Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [ "AWS/ECS", "RunningTaskCount", "ClusterName", aws_ecs_cluster.sejal_cluster.name, "ServiceName", aws_ecs_service.sejal_service.name ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ECS Task Count"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 12

        properties = {
          metrics = [
            [ "AWS/ECS", "NetworkRxBytes", "ClusterName", aws_ecs_cluster.sejal_cluster.name, "ServiceName", aws_ecs_service.sejal_service.name ],
            [ ".", "NetworkTxBytes", ".", ".", ".", "." ]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "ECS Network In/Out"
        }
      }
    ]
  })
}