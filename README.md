## Strapi Deployment on AWS ECS Fargate using Terraform + GitHub Actions
📌 Project Overview

This project deploys a Strapi application on AWS ECS Fargate, fully managed using Terraform and automated through GitHub Actions CI/CD.

The infrastructure includes:

Amazon ECS (Fargate launch type)

Amazon ECR (for Docker images)

Amazon RDS (PostgreSQL – db.t3.micro, Single-AZ)

Amazon S3 (Terraform remote backend)

VPC (default VPC usage)

Security Groups

GitHub Actions workflow for CI/CD

Everything is deployed using Infrastructure as Code (IaC).

## Technologies Used

AWS ECS (Fargate)

AWS ECR

AWS RDS (PostgreSQL – db.t3.micro, Single-AZ)

AWS S3 (Terraform Backend)

Terraform

Docker

GitHub Actions


## CI/CD Workflow (GitHub Actions)

On every push to main branch:

Configure AWS credentials

Login to Amazon ECR

Build Docker image

Tag image with commit SHA

Push image to ECR

Run Terraform apply

Update ECS task revision automatically

## Database Configuration

RDS Configuration:

Engine: PostgreSQL

Instance type: db.t3.micro

Deployment type: Single-AZ

Public access: Disabled

## Environment variables passed to ECS:

DATABASE_CLIENT=postgres
DATABASE_HOST=<RDS endpoint>
DATABASE_PORT=5432
DATABASE_NAME=postgres
DATABASE_USERNAME=<username>
DATABASE_PASSWORD=<password>


## GitHub Secrets Required

Add these in repository → Settings → Secrets:

AWS_ACCESS_KEY

AWS_SECRET_KEY

## Accessing Strapi

After deployment:

Go to ECS → Cluster → Service → Tasks

Get the Public IP of the running task

Open:

http://<public-ip>:1337/admin
