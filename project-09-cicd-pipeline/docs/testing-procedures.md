# Testing Procedures

1. Open the public IP of your EC2 instance in a web browser. You should see "Version 1" of your application.
2. Modify `index.html` locally to say "Version 2".
3. Commit and push the changes:
   ```bash
   git add .
   git commit -m "Update to version 2"
   git push origin main
   ```
4. Navigate to the CodePipeline console. You will see the pipeline automatically transition to In Progress.
5. Watch the Source, Build, and Deploy stages succeed.
6. Refresh your web browser. The application should instantly display "Version 2".