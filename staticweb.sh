#!/bin/bash

# Beginner-Level DevOps Project: Deploy Static Website on AWS

# Prerequisites
# Ensure you have an AWS account and AWS CLI configured with appropriate credentials.

# Create a new S3 bucket
aws s3api create-bucket --bucket my-static-website-bucket --region us-east-1

#  Upload website files to S3 bucket
aws s3 sync /mnt/c/dumpstack.log s3://my-static-website-bucket

# Step 4: Configure bucket for static website hosting
aws s3 website s3://my-static-website-bucket --index-document index.html

# Create an S3 policy for public website access
aws s3api put-bucket-policy --bucket my-static-website-bucket --policy '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-static-website-bucket/*"
    }
  ]
}'

#Enable website hosting on S3 bucket
aws s3api put-bucket-website --bucket my-static-website-bucket --website-configuration '{
  "IndexDocument": {
    "Suffix": "index.html"
  }
}'

# Create a CloudFront distribution
aws cloudfront create-distribution --origin-domain-name my-static-website-bucket.s3.amazonaws.com

# Conclusion
echo "Static website successfully deployed on AWS using Linux."

