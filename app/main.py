import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), ".." )))


from services.reviewer import build_review_prompt
from services.openai_service import invoke
from services.knowledge_loader import load_knowledge
from services.plan_parser import extract_resources_changes
from services.risk_parser import extract_risk_score

with open("terraform/tfplan.json", 'r') as f:
    plan = f.read()

resources_changes = extract_resources_changes(plan)
knowledge = load_knowledge()
prompt = build_review_prompt(resources_changes, knowledge)
review = invoke(prompt)
risk_score = extract_risk_score(review)
print(review)

with open("review.md", 'w') as f:
    f.write(review)

print(f"Risk Score: {risk_score}")

with open("risk_score.txt", "w") as f:
    f.write(str(risk_score))

#if risk_score >= 8:
 #   print("Critical risk detected. Failing pipeline.")
  #  exit(1)
