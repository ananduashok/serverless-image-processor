# 🚀 Serverless Event-Driven Image Processor

## 📌 Project Overview
This project implements a highly scalable, asynchronous image processing pipeline using a serverless architecture on AWS. The goal was to demonstrate the implementation of an event-driven design where components are decoupled and scale automatically based on demand.

### 🏗️ Architecture
**Workflow:** 
`User Upload (S3)` $\rightarrow$ `Event Trigger` $\rightarrow$ `AWS Lambda` $\rightarrow$ `Processed Storage (S3)` & `Metadata Store (DynamoDB)` $\rightarrow$ `Notification (SNS)`

**Tech Stack:**
- **Infrastructure as Code:** Terraform
- **Compute:** AWS Lambda (Python 3.9)
- **Storage:** Amazon S3
- **Database:** Amazon DynamoDB (NoSQL)
- **Messaging:** Amazon SNS
- **Monitoring:** AWS CloudWatch

---

### 1. Principle of Least Privilege (PoLP)
Instead of using managed admin policies, I implemented custom IAM roles with granular permissions. The Lambda function only has `s3:GetObject` for the source bucket and `s3:PutObject` for the destination bucket, minimizing the blast radius in case of a security breach.

### 2. Event-Driven Decoupling
By using S3 Event Notifications, the system is completely asynchronous. The upload process does not wait for the image to be processed, ensuring a high-performance user experience.

### 3. Idempotency & Scalability
The use of DynamoDB as a metadata store allows the system to track processed images, preventing duplicate processing and ensuring the system can handle thousands of concurrent uploads via Lambda's native scaling.

---

## 🛠️ Deployment Guide

### Prerequisites
- AWS CLI configured
- Terraform installed

### Steps
1. Clone the repo: `git clone https://github.com/ananduashok/serverless-image-processor`
2. Initialize Terraform: `terraform init`
3. Deploy Infrastructure: `terraform apply -auto-approve`
4. Test the pipeline:
   ```bash
   aws s3 cp test-image.jpg s3://<your-source-bucket>/
