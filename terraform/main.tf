# Provider configuration
provider "aws" {
  region = var.aws_region
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Basic Lambda execution policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "api" {
  function_name = var.project_name
  role         = aws_iam_role.lambda_role.arn
  handler      = "lambda_handler.handler"
  runtime      = "python3.11"

  filename         = var.lambda_deployment_package
  source_code_hash = filebase64sha256(var.lambda_deployment_package)

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      OPENEMR_BASE_URL     = var.openemr_base_url
      OPENEMR_CLIENT_ID    = var.openemr_client_id
      OPENEMR_CLIENT_SECRET = var.openemr_client_secret
      OPENEMR_REDIRECT_URI = var.openemr_redirect_uri != "" ? var.openemr_redirect_uri : "https://${aws_apigatewayv2_api.main.id}.execute-api.${var.aws_region}.amazonaws.com/oauth/callback"
    }
  }
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "main" {
  name          = var.project_name
  protocol_type = "HTTP"
  description   = "OpenEMR API FastAPI Interface"
}

# Lambda integration
resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Default route - proxy all requests to Lambda
resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Stage (required for API Gateway)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

# Lambda permission for API Gateway to invoke
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
