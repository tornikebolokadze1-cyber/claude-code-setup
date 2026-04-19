# Credentials Setup

n8n manages credentials separately from workflows. When you import a workflow,
you must configure the credentials it references on the target instance.

## How n8n Credentials Work

- Credentials are stored encrypted on the n8n instance.
- Workflow JSON files reference credentials by **name**, not by secret values.
- When importing a workflow, n8n will show a warning if referenced credentials
  do not exist on the instance. You must create them before activating the workflow.

## Setting Up Credentials

### Via the n8n UI

1. Open your n8n instance.
2. Go to **Credentials** in the left sidebar.
3. Click **Add Credential**.
4. Search for the service (e.g., "Slack", "Google Sheets", "HTTP Request").
5. Fill in the required fields (API key, OAuth tokens, etc.).
6. Click **Save** and test the connection if a test button is available.

### Credential Types Used in This Project

Document each credential your workflows need:

| Credential Name      | Type              | Required By              | Notes                       |
|----------------------|-------------------|--------------------------|-----------------------------|
| *(add yours here)*   | *(e.g., API Key)* | *(workflow name)*        | *(where to get the key)*   |

## Common Credential Types

### API Key

For services that use a simple API key:
1. Create an API key in the service's dashboard.
2. In n8n, add a credential of type **Header Auth** or the service-specific node.
3. Paste the API key.

### OAuth2

For services that use OAuth (Google, Slack, Microsoft, etc.):
1. Create an OAuth app in the service's developer portal.
2. Set the redirect URL to your n8n instance:
   `https://<your-instance>.app.n8n.cloud/rest/oauth2-credential/callback`
3. In n8n, add the credential and click **Connect** to complete the OAuth flow.

### HTTP Header Auth

For generic APIs:
1. Add a **Header Auth** credential.
2. Set the header name (e.g., `Authorization`) and value (e.g., `Bearer <token>`).

### Basic Auth

For services using username/password:
1. Add a **HTTP Basic Auth** credential.
2. Enter the username and password.

## Security Best Practices

- **Never commit secrets** to this repository. Use `.env` files locally and
  configure credentials directly in the n8n UI.
- **Restrict credential sharing** in n8n to only the users who need them.
- **Rotate keys regularly** and update them in the n8n credentials UI.
- **Use environment variables** in self-hosted n8n for sensitive values.
- **Audit credential usage** periodically — remove credentials no longer in use.

## Troubleshooting

| Problem                          | Solution                                               |
|----------------------------------|--------------------------------------------------------|
| "Credential not found" error     | Create the credential with the exact name the workflow expects |
| OAuth flow fails                 | Check redirect URL matches your n8n instance URL       |
| "Unauthorized" on execution      | Verify the API key/token is valid and has correct scopes |
| Credential works in test but not in execution | Check that the credential is shared with the workflow owner |
