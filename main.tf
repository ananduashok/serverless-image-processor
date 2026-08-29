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