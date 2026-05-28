## S3 Storage Classes Reference

| Storage Class | Best For | Retrieval Time | vs Standard |
|---|---|---|---|
| S3 Standard | Frequently accessed — daily use | Instant | Baseline |
| S3 Standard-IA | Infrequent — accessed monthly | Instant | ~58% cheaper |
| S3 Glacier Instant | Archives — accessed quarterly | Instant | ~68% cheaper |
| S3 Glacier Flexible | Long-term archives | 1–12 hours | ~85% cheaper |
| S3 Glacier Deep Archive | 7–10 year retention | 12–48 hours | ~95% cheaper |

> Lifecycle policies automate moving objects through these classes —
> this is how companies save thousands per month on S3 without
> any manual intervention.