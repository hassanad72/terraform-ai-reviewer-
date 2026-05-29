import json

def extract_resources_changes(plan_json_text):
    plan = json.loads(plan_json_text)
    
    resource_changes = plan.get("resource_changes", [])

    return json.dumps(resource_changes, indent=2)