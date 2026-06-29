#!/bin/bash

# =============================================================================
# Project 6 — Script 09: RDS Operations
# Covers describe, snapshot, stop, start, and modify operations
# =============================================================================

echo -e "\e[36m=== Project 6 — RDS Operations ===\e[0m"
echo ""

DB_ID="myapp-database"

# ── DESCRIBE INSTANCE ─────────────────────────────────────────────────────────
echo -e "\e[33m--- Instance Details ---\e[0m"
aws rds describe-db-instances \
    --db-instance-identifier $DB_ID \
    --query "DBInstances[0].{
    ID:DBInstanceIdentifier,
    Class:DBInstanceClass,
    Engine:Engine,
    EngineVersion:EngineVersion,
    Status:DBInstanceStatus,
    Endpoint:Endpoint.Address,
    Port:Endpoint.Port,
    Storage_GiB:AllocatedStorage,
    StorageType:StorageType,
    PublicAccess:PubliclyAccessible,
    MultiAZ:MultiAZ,
    BackupRetentionDays:BackupRetentionPeriod,
    Encrypted:StorageEncrypted,
    AZ:AvailabilityZone
  }" \
    --output table

# ── CREATE MANUAL SNAPSHOT ────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Creating Manual Snapshot ---\e[0m"

$SNAPSHOT_ID = "myapp-manual-snapshot-$(date +"%T")"
echo "Snapshot ID: $SNAPSHOT_ID"

aws rds create-db-snapshot \
    --db-instance-identifier $DB_ID \
    --db-snapshot-identifier $SNAPSHOT_ID | Out-Null

echo -e "\e[32mSnapshot creation initiated.\e[0m"
echo "(Snapshot takes a few minutes — check status in RDS console)"

# ── LIST ALL SNAPSHOTS ────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- All Snapshots for $DB_ID ---\e[0m"
aws rds describe-db-snapshots \
    --db-instance-identifier $DB_ID \
    --query "DBSnapshots[*].{ID:DBSnapshotIdentifier,Status:Status,Type:SnapshotType,Created:SnapshotCreateTime,Size_GiB:AllocatedStorage}" \
    --output table

# ── MODIFY BACKUP RETENTION ───────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Modifying Backup Retention to 3 days ---\e[0m"

aws rds modify-db-instance \
    --db-instance-identifier $DB_ID \
    --backup-retention-period 3 \
    --apply-immediately | Out-Null

echo -e "\e[32mBackup retention updated to 3 days.\e[0m"

# ── SHOW EVENTS ───────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Recent RDS Events ---\e[0m"
aws rds describe-events \
    --source-identifier $DB_ID \
    --source-type db-instance \
    --duration 60 \
    --query "Events[*].{Time:Date,Message:Message}" \
    --output table

# ── STOP INSTANCE (OPTIONAL / COST SAVING) ───────────────────────────────────
echo ""
echo -e "\e[33m--- Stop / Start Commands (for reference) ---\e[0m"
echo ""
echo "To STOP RDS (saves cost — max 7 days, then auto-starts):"
echo "  aws rds stop-db-instance --db-instance-identifier $DB_ID"
echo ""
echo "To START RDS after stopping:"
echo "  aws rds start-db-instance --db-instance-identifier $DB_ID"
echo ""
echo "NOTE: Do not stop if you plan to keep using it today."
echo "      For permanent removal, use the cleanup script instead."
echo ""
echo -e "\e[36m=== RDS Operations Complete ===\e[0m"
echo ""
echo -e "\e[36mNext step: When done with the project, run 10-cleanup.ps1\e[0m"