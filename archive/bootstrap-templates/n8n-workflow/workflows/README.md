# Workflows

This directory contains exported n8n workflow JSON files. Each file represents
a complete workflow that can be imported into any n8n instance.

## Importing a Workflow

### Via the n8n UI

1. Open your n8n instance.
2. Go to **Workflows** in the left sidebar.
3. Click the **"..."** menu (top-right) and select **Import from File**.
4. Select the `.json` file from this directory.
5. The workflow opens in the editor — review it, then click **Save**.
6. Set up any required credentials (see `docs/credentials-setup.md`).
7. Toggle the workflow **Active** when ready.

### Via the n8n API

```bash
# Set your environment variables (copy .env.example to .env and fill in values)
source .env

# Deploy a specific workflow
./scripts/deploy-workflow.sh workflows/example-webhook-processor.json
```

### Via n8n MCP Tools (recommended for Claude-assisted projects)

```
# Create a new workflow from JSON
n8n_create_workflow <workflow-json>

# Update an existing workflow (partial update — saves tokens)
n8n_update_partial_workflow <workflow-id> <partial-json>
```

## Exporting a Workflow

### From the n8n UI

1. Open the workflow in the n8n editor.
2. Click the **"..."** menu (top-right) and select **Download**.
3. Save the JSON file to this directory with a descriptive kebab-case name.
4. Commit the file to version control.

### From the n8n API

```bash
source .env
curl -s -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
  "${N8N_INSTANCE_URL}/api/v1/workflows/<workflow-id>" \
  | jq '.' > workflows/<name>.json
```

## Management Best Practices

- **Version control**: Always commit workflow changes so you can diff and rollback.
- **One workflow per file**: Keep each workflow in its own JSON file.
- **Never edit JSON by hand**: Use the n8n editor or MCP tools. The JSON schema
  has internal references (node positions, connections) that are easy to break.
- **Credential placeholders**: Exported workflows include credential *names* but
  not secrets. You must configure credentials on the target instance separately.
- **Test before activating**: Import into a staging instance or keep the workflow
  inactive until you have verified it works.
- **Back up regularly**: Run `scripts/backup-workflows.sh` before making changes
  to production workflows.
