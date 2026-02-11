variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project/application name used for resource naming"
  type        = string
  default     = "openemr-api"
}

variable "openemr_base_url" {
  description = "OpenEMR server base URL"
  type        = string
}

variable "openemr_client_id" {
  description = "OpenEMR OAuth client ID"
  type        = string
  sensitive   = true
}

variable "openemr_client_secret" {
  description = "OpenEMR OAuth client secret"
  type        = string
  sensitive   = true
}

variable "openemr_redirect_uri" {
  description = "OAuth redirect URI (will be set to API Gateway URL after deployment)"
  type        = string
  default     = ""
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_deployment_package" {
  description = "Path to the Lambda deployment zip file"
  type        = string
  default     = "lambda.zip"
}
