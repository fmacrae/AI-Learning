#!/usr/bin/env python
# coding: utf-8


import sagemaker
import boto3
import sys
import os
import glob
import re
import subprocess
from time import gmtime, strftime
sys.path.append("common")

# S3 bucket
boto_session = boto3.session.Session(
    aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID", "minio"), 
    aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY", "miniokey"),
    region_name=os.environ.get("AWS_REGION", "us-east-1"))
s3Client = boto_session.resource("s3", use_ssl=False,
endpoint_url=os.environ.get("S3_ENDPOINT_URL", "http://127.0.0.1:9000"))

try:
    s3Client.create_bucket(Bucket='bucket')
except:
    print("ERROR  oops bucket creation error may have to do manually")
filename1 = 'model_metadata.json'
filename2 = 'reward.py'
bucket_name = 'bucket'

# Uploads the given file using a managed uploader, which will split up large
# files automatically and upload parts in parallel.
try:
    s3Client.meta.client.upload_file('../custom_files/'+filename1, bucket_name, 'custom_files/'+filename1)
except:
    print("ERROR " + filename1 + "  copy of custom_files errored to the bucket check and do manually")
try:
    s3Client.meta.client.upload_file('../custom_files/'+filename2, bucket_name, 'custom_files/'+filename2)
except:
    print("ERROR " + filename2 + "  copy of custom_files errored to the bucket check and do manually")
