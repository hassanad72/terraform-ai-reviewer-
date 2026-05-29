import boto3
import json

bedrock = boto3.client(
    service_name="bedrock-runtime",
    region_name="us-east-1"
)

def invoke(prompt):
    body = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 1000,
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ]
    }
    response = bedrock.invoke_model(
        modelId="anthropic.claude-3-haiku-20240307",
        body=json.dumps(body)
    )
    response_body = json.loads(response['body'].read())
    return response_body["content"][0]["text"]