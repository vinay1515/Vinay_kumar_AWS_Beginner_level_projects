import os

base_dir = r"e:\AWS Hands-on Projects\project-07-cloudwatch-monitoring\docs"

files_to_fix = {
    "cloudwatch-alarms.md": "# CloudWatch Alarms\n\n",
    "dashboards.md": "# CloudWatch Dashboards\n\n",
    "logs-and-metric-filters.md": "# Logs and Metric Filters\n\n",
    "monitoring-strategy.md": "# Monitoring Strategy\n\n"
}

for filename, heading in files_to_fix.items():
    path = os.path.join(base_dir, filename)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Don't add if it already starts with #
    if not content.startswith("#"):
        new_content = heading + content
        with open(path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"Added H1 heading to {filename}")

print("Done fixing headings.")
