### 📊 Storage Class Comparison Matrix

| Storage Class | Primary Use Case | Retrieval Time | Durability / Availability | Cost Comparison vs Standard |
|---|---|---|---|---|
| **S3 Standard** | Frequently accessed data, active applications, mobile gaming, dynamic websites. | Milliseconds (Instant) | 99.999999999% / 99.99% | Baseline ($0.023 per GB) |
| **S3 Intelligent-Tiering** | Data with unknown or changing access patterns. AWS automatically moves data to the cheapest tier based on usage. | Milliseconds | 99.999999999% / 99.9% | Variable + Monitoring Fee |
| **S3 Standard-IA** | Infrequent access but requires rapid access when needed (e.g., disaster recovery backups, monthly reports). | Milliseconds (Instant) | 99.999999999% / 99.9% | **~58% cheaper**, but carries a per-GB retrieval fee. |
| **S3 Glacier Instant Retrieval** | Archival data accessed perhaps once a quarter, but requires immediate access when queried (e.g., medical images). | Milliseconds (Instant) | 99.999999999% / 99.9% | **~68% cheaper**, with higher retrieval fees. |
| **S3 Glacier Flexible Retrieval** | Long-term archives, backup data, compliance logs where a delay is acceptable. | 1 to 12 hours | 99.999999999% / 99.99% | **~85% cheaper** ($0.0036 per GB). |
| **S3 Glacier Deep Archive** | Extreme long-term retention (7–10 years) for regulatory compliance (e.g., Financial/Healthcare records). | 12 to 48 hours | 99.999999999% / 99.99% | **~95% cheaper** ($0.00099 per GB). |

---

### 💸 The Hidden Costs: Retrieval Fees & Minimum Storage Durations

When optimizing costs, many beginners simply look at the storage price and immediately move everything to Glacier. This is a costly mistake.

1. **Retrieval Fees:** While `Standard-IA` and `Glacier` are cheaper to *store* data, AWS charges a premium to *retrieve* (read) that data. If you put a highly trafficked website image in `Standard-IA`, the retrieval fees will vastly exceed what you saved on storage.
2. **Minimum Storage Duration:** `Standard-IA` has a minimum storage duration of 30 days. `Glacier Deep Archive` has a minimum of 180 days. If you upload a file to Deep Archive and delete it the next day, AWS will still charge you for 180 days of storage.

---

### 🤖 Automating Tiering with Lifecycle Policies

In enterprise environments, data is rarely moved manually. We use **S3 Lifecycle Policies** to evaluate objects daily and "waterfall" them down to cheaper tiers as they age.

**A Common Enterprise Lifecycle Strategy:**
- **Day 0:** Object created in `S3 Standard` (Active development).
- **Day 30:** Object transitioned to `S3 Standard-IA` (Project finishes, data is accessed less frequently).
- **Day 90:** Object transitioned to `S3 Glacier Flexible Retrieval` (Data is retained for auditing purposes).
- **Day 365:** Object is Permanently Deleted / Expired (Data is no longer legally required to be retained).

> [!TIP]
> **Versioning Impact:** Remember that when versioning is enabled, modifying an object creates a new "Current" version and pushes the old data into a "Noncurrent" version. Lifecycle policies allow you to apply completely different transition rules to Noncurrent versions, aggressively moving old drafts to Glacier while keeping the Current version in Standard.