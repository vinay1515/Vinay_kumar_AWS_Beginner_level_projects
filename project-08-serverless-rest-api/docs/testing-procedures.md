# Testing Procedures

Use `curl` or Postman to test the API endpoints using the Invoke URL provided by API Gateway.

## Create User (POST)
```bash
curl -X POST https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/users \
-H "Content-Type: application/json" \
-d '{"userId": "1", "name": "Cloud Engineer"}'
```

## Get All Users (GET)
```bash
curl -X GET https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/users
```

## Get Single User (GET)
```bash
curl -X GET https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/users/1
```

## Delete User (DELETE)
```bash
curl -X DELETE https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/users/1
```