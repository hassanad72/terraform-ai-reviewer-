def build_review_prompt(terraform_plan, knowledge):

    return f"""
You are a senior DevOps, platform engineering, and cloud security expert.

Use these company standards while reviewing the Terraform plan.

Company Standards:

{knowledge}

Review this Terraform execution plan.

Focus on:

1. Security risks
2. Networking risks
3. IAM risks
4. Destructive infrastructure changes
5. Cost concerns
6. Best practice violations
7. Company policy violations

Terraform Plan JSON:

{terraform_plan}

Return your response in this format:

Summary:
Risks:
Recommendations:
Severity:
"""