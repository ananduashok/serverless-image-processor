provider "aws" {
    region = var.aws_region
}

#source bucket
resource "aws_s3_bucket" "source_bucket" {
    bucket = "${var.project_name}-source-${random_id.suffix.hex}"
}

#destination bucket
resource "aws_s3_bucket" "dest_bucket" {
    bucket = "${var.project_name}-processed-${random_id.suffix.hex}"
}

#random suffix to ensure bucket names are globally unique
resource "random_id" "suffix" {
    byte_length = 4
}

#dynamodb table to store image metadata
resource "aws_dynamodb_table" "image_metadata" {
    name = "${var.project_name}-metadata"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "ImageID"

    attribute {
        name = "ImageID"
        type = "S"
    }
}

#sns topic for notifications
resource "aws_sns_topic" "processing_notification" {
    name = "${var.project_name}-notifications"
}

# Zip the lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda_function_payload.zip"
}

# The Lambda Function
resource "aws_lambda_function" "processor" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.dest_bucket.id
      TABLE_NAME  = aws_dynamodb_table.image_metadata.name
      SNS_TOPIC   = aws_sns_topic.processing_notification.arn
    }
  }
}

# S3 Trigger: Tell S3 to call Lambda when a file is uploaded
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}
