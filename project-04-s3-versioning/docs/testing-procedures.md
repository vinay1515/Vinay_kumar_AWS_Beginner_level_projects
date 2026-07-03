# Testing Procedures

## Test Versioning
1. Upload a file named `doc.txt`.
2. Edit `doc.txt` locally, and upload it again to the source bucket.
3. In the console, toggle "Show Versions". You will see two versions of `doc.txt`.

## Test Deletion
1. Delete `doc.txt` via the console.
2. Toggle "Show Versions". You will see a `Delete Marker` placed on top.
3. Select the Delete Marker and delete it. `doc.txt` is restored.

## Test CRR
1. Upload a new file `test-crr.txt` to the source bucket.
2. Wait ~30 seconds.
3. Navigate to the destination bucket in `ap-south-2`. The file should be present.