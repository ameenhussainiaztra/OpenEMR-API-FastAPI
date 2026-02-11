output "api_url" {
  description = "API Gateway base URL"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "api_docs_url" {
  description = "Swagger UI documentation URL"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}docs"
}

output "oauth_redirect_uri" {
  description = "OAuth redirect URI to configure in OpenEMR"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}oauth/callback"
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.api.function_name
}
