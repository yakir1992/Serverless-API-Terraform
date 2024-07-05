provider "aws" {
  region = "eu-central-1"
}

resource "aws_dynamodb_table" "my-table" {
    name = "my-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
    tags = {
        Name = "MyDynamoDBTable"
    }
  }

resource "aws_api_gateway_rest_api" "my_api" {
  name = "MyAPIGateway"
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "myresource"
}

resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.my_resource.id
  http_method = aws_api_gateway_method.my_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.my_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*"
}

# cloudwatch - real time monitor - automatically alarms if there is any problem

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "LambdaErrorAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors Lambda errors"
  actions_enabled     = true
  alarm_actions       = []

  dimensions = {
    FunctionName = aws_lambda_function.my_lambda.function_name
  }
}

# Cognito user authentication

resource "aws_cognito_user_pool" "my_user_pool" {
  name = "my_user_pool"
}

resource "aws_cognito_user_pool_client" "my_user_pool_client" {
  name         = "my_user_pool_client"
  user_pool_id = aws_cognito_user_pool.my_user_pool.id
}
