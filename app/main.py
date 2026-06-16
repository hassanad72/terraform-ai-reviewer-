import sys
import os
import json 
import boto3

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), ".." )))


def download_tfplan_if_needed() -> None:
    s3_plan_path = os.environ.get("S3_PLAN_PATH")
    if not s3_plan_path:
        return

    if not s3_plan_path.startswith("s3://"):
        raise ValueError(f"S3_PLAN_PATH must be an s3:// URL, got: {s3_plan_path}")

    _, path = s3_plan_path.split("s3://", 1)
    bucket, key = path.split("/", 1)
    local_path = os.path.join("terraform", "tfplan.json")
    os.makedirs(os.path.dirname(local_path), exist_ok=True)

    s3 = boto3.client(
        "s3",
        region_name=os.environ.get("AWS_DEFAULT_REGION", "us-east-1"),
    )
    print(f"Downloading tfplan from {s3_plan_path} to {local_path}")
    s3.download_file(bucket, key, local_path)
    print("tfplan download complete")


from services.reviewer import build_review_prompt
from services.openai_service import invoke
from services.knowledge_loader import load_knowledge
from services.plan_parser import extract_resources_changes
from services.risk_parser import extract_risk_score
from services.config_loader import load_config
from services.scoring import calculate_risk_score

download_tfplan_if_needed()

with open("terraform/tfplan.json", 'r') as f:
    plan = f.read()

resources_changes = extract_resources_changes(plan)

knowledge = load_knowledge()
prompt = build_review_prompt(resources_changes, knowledge)
review = invoke(prompt)

deterministic_score = calculate_risk_score(resources_changes)
ai_score = extract_risk_score(review)


risk_score = deterministic_score   
config = load_config()
environment = config["environment"]
risk_threshold = config["risk_thresholds"][environment]
print(f"Risk Threshold: {risk_threshold}")
print(review)
print(f"Environment: {environment}")
print(f"Deterministic Score: {deterministic_score}")
print(f"AI Score: {ai_score}")
print(f"Offical Risk Score: {risk_score}")

with open("review.md", 'w') as f:
    f.write(review)

with open("risk_score.txt", "w") as f:
    f.write(str(risk_score))

with open("risk_threshold.txt", "w") as f:
    f.write(str(risk_threshold))

decision = "PASS" if risk_score < risk_threshold else "FAIL"
print(f"Pipeline Decision: {decision}")

with open("pipeline_decision.txt", "w") as f:
    f.write(decision)
#if risk_score >= 8:
 #   print("Critical risk detected. Failing pipeline.")
  #  exit(1)
