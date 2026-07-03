# Architecture Details

## Source Bucket
- Hosted in `ap-south-1`.
- **Versioning:** Enabled. Every update creates a new object version rather than overwriting. Deletions create a "Delete Marker" that can be removed to restore the file.
- **Lifecycle Policies:** 
  - Day 30: Move current objects to `STANDARD_IA`.
  - Day 90: Move current objects to `GLACIER`.

## Disaster Recovery
- **IAM Role:** An identity created to allow the S3 service to read objects from the source bucket and write them to the destination.
- **Destination Bucket:** Hosted in `ap-south-2`. Replicates objects asynchronously immediately upon upload to the source.