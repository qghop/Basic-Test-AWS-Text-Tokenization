import boto3 #type: ignore
import os
import csv
import re
from urllib.parse import unquote_plus

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = unquote_plus(event['Records'][0]['s3']['object']['key'])

    local_path = '/tmp/input.txt'
    output_path = '/tmp/tokenized.csv'

    s3.download_file(bucket, key, local_path)

    with open(local_path, 'r') as f:
        text = f.read()
    tokens = re.findall(r'\b\w+\b', text)

    with open(output_path, 'w', newline='') as f:
        writer = csv.writer(f)
        for word in tokens:
            writer.writerow([word])

    s3.upload_file(output_path, os.environ['OUTPUT_BUCKET'], key.replace(".txt", "_tokens.csv"))

    return {"status": "done", "words": len(tokens)}