## Basic AWS Test - Text Tokenization

Basic working AWS S3 and Lambda setup with Terraform. Takes an input txt file, tokenizes, and outputs a csv file.

### Setup

```bash
cd lambda
zip tokenizer.zip tokenizer.py
```

```bash
cd terraform
terraform init
terraform apply
```

```bash
aws s3 cp inputs/sample.txt s3://text-tokenizer-bucket/
```

