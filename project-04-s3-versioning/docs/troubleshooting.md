# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **Replication fails to start** | Versioning Disabled | CRR absolutely requires versioning to be enabled on *both* the source and destination buckets. |
| **Object uploaded but not in replica** | Existing Objects | CRR only replicates *new* objects uploaded after the rule is created. It does not replicate existing objects retrospectively. |
| **Can't delete bucket** | Hidden Versions | You cannot delete a bucket that contains objects. If versioning is enabled, you must toggle "Show Versions" and delete all versions and delete markers first. |