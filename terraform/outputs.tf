output "ecr_repository_url" {
  value = aws_ecr_repository.strapi_repo.repository_url
}

output "rds_endpoint" {
  value = aws_db_instance.strapi_db.endpoint
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.sejal_cluster.name
}
