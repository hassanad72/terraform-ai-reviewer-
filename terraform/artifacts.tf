resource "aws_s3_bucket" "ai_reviewer_bucket" {
  bucket = "terraform-ai-reviewer-bucket-505342848876"
  
    tags = {
        Name        = "terraform-ai-reviewer-bucket"
    }

}