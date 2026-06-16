# Bedrock Knowledge Base

#DATA sources
data "aws_bedrock_foundation_model" "titan_embeddings" {
  model_id = "amazon.titan-embed-text-v1"
}

#IAM role for knowledge base
resource "aws_iam_role" "knowledge_base_role" {
  name = "knowledge-base-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy" "knowledge_base_policy" {
  name = "knowledge-base-policy"
  role = aws_iam_role.knowledge_base_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.knowledge_base_bucket.arn,
          "${aws_s3_bucket.knowledge_base_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "aoss:CreateIndex",
          "aoss:DescribeIndex",
          "aoss:DeleteIndex",
          "aoss:UpdateIndex",
          "aoss:Search",
          "aoss:APIAccessALL"
        ]
        Resource = [
          aws_opensearchserverless_collection.knowledge_base_collection.arn,
          "${aws_opensearchserverless_collection.knowledge_base_collection.arn}/*"
        ]
      },
       {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          data.aws_bedrock_foundation_model.titan_embeddings.model_arn
        ]
       }
    ]
  })
}

resource "aws_opensearchserverless_security_policy" "kb_encryption" {
  name = "ai-reviewer-encryption"
  type = "encryption"

  policy = jsonencode({
    Rules = [{
      Resource     = ["collection/knowledge-base-collection"]
      ResourceType = "collection"
    }]
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "kb_network" {
  name = "ai-reviewer-network"
  type = "network"

  policy = jsonencode([{
    Rules = [{
      Resource     = ["collection/knowledge-base-collection"]
      ResourceType = "collection"
    }]
    AllowFromPublic = true
  }])
}

resource "aws_opensearchserverless_collection" "knowledge_base_collection" {
  name = "knowledge-base-collection"
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.kb_encryption,
    aws_opensearchserverless_security_policy.kb_network
  ]
}

resource "aws_opensearchserverless_access_policy" "kb_data_access" {
  name = "ai-reviewer-data-access"
  type = "data"

  policy = jsonencode([{
    Rules = [
      {
        Resource     = ["collection/knowledge-base-collection"]
        Permission   = ["aoss:*"]
        ResourceType = "collection"
      },
      {
        Resource     = ["index/knowledge-base-collection/*"]
        Permission   = ["aoss:*"]
        ResourceType = "index"
      }
    ]
    Principal = [aws_iam_role.knowledge_base_role.arn, "arn:aws:iam::505342848876:root"]
  }])

}

resource "aws_bedrockagent_knowledge_base" "ai_reviewer_kb" {
  name     = "ai-reviewer-knowledge-base"
  role_arn = aws_iam_role.knowledge_base_role.arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.titan_embeddings.model_arn
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"

    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.knowledge_base_collection.arn
      vector_index_name = opensearch_index.ai_reviewer_index.name

      field_mapping {
        vector_field   = "vector"
        text_field     = "text"
        metadata_field = "metadata"
      }
    }
  }

  depends_on = [opensearch_index.ai_reviewer_index, aws_iam_role_policy.knowledge_base_policy]
}

resource "aws_bedrockagent_data_source" "ai-reviewer_data_source" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.ai_reviewer_kb.id
  name              = "ai-reviewer-data-source"

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = aws_s3_bucket.knowledge_base_bucket.arn
    }
  }

}