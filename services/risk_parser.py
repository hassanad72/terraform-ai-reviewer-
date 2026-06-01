import re 

def extract_risk_score(review_text):

    match = re.search(r"Risk Score:\s*(\d+)", review_text)

    if match:
        return int(match.group(1))

    return 0