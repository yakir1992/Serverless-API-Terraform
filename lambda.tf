# IAM role that Lambda will assume
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the basic execution policy to the role
resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Define the Lambda function
resource "aws_lambda_function" "my_lambda" {
  filename         = "${path.module}/lambda/function.zip"  # Path to the ZIP file
  function_name    = "MyLambdaFunction"                    # Name of the Lambda function
  role             = aws_iam_role.lambda_execution_role.arn  # IAM role ARN
  handler          = "function.lambda_handler"             # Handler name (file_name.handler_function)
  runtime          = "python3.8"                           # Runtime environment
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip") # Ensure new version is uploaded when code changes
}