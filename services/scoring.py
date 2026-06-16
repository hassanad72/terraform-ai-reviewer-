def calculate_risk_score(resource_changes):
    score = 0

    if "0.0.0.0/0" in resource_changes:
        score += 7
    if "aws_security_group" in resource_changes:
        score += 2
    if "tag" not in resource_changes:
        score += 2
    if "vpc_id" not in resource_changes:
        score += 2
    if score > 10:
        score = 10
    return score