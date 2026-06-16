# knowledge base index

terraform {
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.3"
    }
  }
}

provider "opensearch" {
  url         = aws_opensearchserverless_collection.knowledge_base_collection.collection_endpoint
  healthcheck = false
}

resource "opensearch_index" "ai_reviewer_index" {
  name      = "ai-reviewer-index"
  index_knn = true

  mappings = jsonencode({
    properties = {
      vector = {
        type      = "knn_vector"
        dimension = 1536

        method = {
          name       = "hnsw"
          engine     = "faiss"
          space_type = "innerproduct"
        }
      }
      text = {
        type = "text"
      }
      metadata = {
        type = "text"
        index = false
      }
    }
  })
  depends_on = [aws_opensearchserverless_access_policy.kb_data_access, aws_opensearchserverless_collection.knowledge_base_collection]
}