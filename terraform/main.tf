provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "text_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.text_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.text_tokenizer.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = ""
    filter_suffix       = ".txt"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke,
    aws_lambda_function.text_tokenizer
  ]
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.text_tokenizer.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.text_bucket.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "LambdaS3AccessPolicy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.text_bucket.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_lambda_function" "text_tokenizer" {
  filename         = "${path.module}/../lambda/tokenizer.zip"
  function_name    = "TextTokenizer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "tokenizer.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("${path.module}/../lambda/tokenizer.zip")
  environment {
    variables = {
      OUTPUT_BUCKET = var.s3_bucket_name
    }
  }
}