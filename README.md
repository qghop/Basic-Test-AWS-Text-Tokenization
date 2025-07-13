## Basic AWS Test - Text Tokenization

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

