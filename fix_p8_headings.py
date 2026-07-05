import os

base_dir = r"e:\AWS Hands-on Projects\project-08-serverless-rest-api\docs"

files_to_fix = {
    "api-endpoints.md": "# Serverless REST API Endpoints\n\n",
    "dynamodb-design.md": "# DynamoDB Single-Table Design\n\n",
    "lambda-design.md": "# Lambda Function Design\n\n",
    "security.md": "# Security Protocols\n\n",
    "testing-guide.md": "# API Testing Guide\n\n"
}

for filename, heading in files_to_fix.items():
    path = os.path.join(base_dir, filename)
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        
        if not content.startswith("#"):
            new_content = heading + content
            with open(path, "w", encoding="utf-8") as f:
                f.write(new_content)
            print(f"Added H1 heading to {filename}")

print("Done fixing headings.")
