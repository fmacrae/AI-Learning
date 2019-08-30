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
from misc import get_execution_role, wait_for_s3_object
from sagemaker.rl import RLEstimator, RLToolkit, RLFramework
from markdown_helper import *

# S3 bucket
boto_session = boto3.session.Session(
    aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID", "minio"), 
    aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY", "miniokey"),
    region_name=os.environ.get("AWS_REGION", "us-east-1"))
s3Client = boto_session.resource("s3", use_ssl=False,
endpoint_url=os.environ.get("S3_ENDPOINT_URL", "http://127.0.0.1:9000"))

s3Client.create_bucket(Bucket='bucket')

filename1 = 'model_metadata.json'
filename2 = 'reward.py'
bucket_name = 'bucket'

# Uploads the given file using a managed uploader, which will split up large
# files automatically and upload parts in parallel.
s3Client.upload_file('~/deepracer/custom_files/'+filename1, bucket_name, '/custom_files/'+filename1)
s3Client.upload_file('~/deepracer/custom_files/'+filename2, bucket_name, '/custom_files/'+filename2)
