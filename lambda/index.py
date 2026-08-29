import json
import boto3
import urllib.parse
import os

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

# These will be passed as environment variables via Terraform
DEST_BUCKET = os.environ['DEST_BUCKET']
TABLE_NAME = os.environ['TABLE_NAME']
SNS_TOPIC = os.environ['SNS_TOPIC']

def lambda_handler(event, context):
    # 1. Get the bucket and object key from the S3 event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    
    try:
        print(f"Processing file {key} from bucket {bucket}...")
        
        # 2. Simulate processing: Copy object to destination bucket with 'thumb_' prefix
        copy_source = {'Bucket': bucket, 'Key': key}
        dest_key = f"thumb_{key}"
        s3.copy_object(CopySource=copy_source, Bucket=DEST_BUCKET, Key=dest_key)
        
        # 3. Store metadata in DynamoDB
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(
            Item={
                'ImageID': key,
                'Status': 'Processed',
                'ThumbnailKey': dest_key,
                'OriginalBucket': bucket
            }
        )
        
        # 4. Send SNS Notification
        sns.publish(
            TopicArn=SNS_TOPIC,
            Message=f"Success! Image {key} has been processed and saved to {DEST_BUCKET}.",
            Subject="Image Processor Notification"
        )
        
        return {'statusCode': 200, 'body': 'Processing Complete'}
        
    except Exception as e:
        print(f"Error: {e}")
        raise e
