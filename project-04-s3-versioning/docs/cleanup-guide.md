# Cleanup Guide

> [!WARNING]
> Because you uploaded files, you will be billed for storage if you do not clean up. Furthermore, if the lifecycle policy moves the object to Glacier, you may be billed an early-deletion fee. Clean up immediately after testing.

1. Navigate to the Source Bucket. Toggle "Show Versions".
2. Select ALL objects, versions, and delete markers, and delete them.
3. Navigate to the Destination Bucket. Toggle "Show Versions".
4. Select ALL objects and versions, and delete them.
5. Delete both buckets.
6. Delete the IAM Replication Role.