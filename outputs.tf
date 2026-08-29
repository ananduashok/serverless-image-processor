output "source_bucket_name" {
    description = "The name of the source S3 bucket where we upload the images"
    value = aws_s3_bucket.source_bucket.id
}

output "destination_bucket_name" {
    description = "The name of the destination S3 bucket where the processed images are stored"
    value = aws_s3_bucket.dest_bucket.id
}

output "dynamodb_table_name" {
    description = "The name of the DynamoDB table where image metadata is stored"
    value = aws_dynamodb_table.image_metadata.name
}

output "sns_topic_arn" {
    description = "The ARN of the SNS topic for notifications"
    value = aws_sns_topic.processing_notification.arn
}
