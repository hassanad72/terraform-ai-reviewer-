resource "aws_s3_bucket" "knowledge_base_bucket" {
  bucket = "ai-reviewer-knowledge-505342848876"
  tags = {
    Name        = "ai-reviewer-knowledge"
    Environment = "dev"
    purpose     = "store-knowledge-base"
  }
}

resource "aws_s3_bucket_versioning" "knowledge_base_bucket_versioning" {
  bucket = aws_s3_bucket.knowledge_base_bucket.id
  versioning_configuration {
    status = "Enabled"
  }

}

resource "aws_s3_bucket_public_access_block" "knowledge_base_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.knowledge_base_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}