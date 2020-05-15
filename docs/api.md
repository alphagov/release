# Release API

The Release app exposes information about GOV.UK applications a RESTful API.

Current implemented endpoints are oulined below:


## Show Application: GET `/api/application/:id`

Get information about a specific application where `:id` is the application shortname.

### Success Response

Code: `200 OK`

Examples:
```json
{
   "name": "Smart Answers",
   "shortname": "smartanswers",
   "archived": false,
   "deploy_freeze": true,
   "notes": "",
   "repository_url": "https://github.com/alphagov/smart-answers",
   "hosted_on_aws": true
}
```


### Error Responses

Code: `404 Resource not found`

```json
{
   "status": 404,
   "error": "Not found"
}
```
