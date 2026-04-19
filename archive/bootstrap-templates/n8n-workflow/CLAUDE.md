# n8n Workflow Project Rules

## Instance

- Production instance: `aipulsegeorgia2025.app.n8n.cloud`
- Always confirm which instance you are targeting before making changes.

## Build Order

Follow this sequence when creating or modifying workflows:

1. **Patterns** — Identify the automation pattern (webhook, schedule, event-driven)
2. **Find nodes** — Search for the right n8n nodes (`search_nodes`, `search_templates`)
3. **Configure** — Set node parameters correctly
4. **Expressions** — Use `={{ }}` syntax (always include the `=` prefix)
5. **Code nodes** — No braces around expressions; return `[{json: {...}}]`
6. **Validate** — Run `n8n_validate_workflow` before deploying
7. **Auto-fix** — Use `n8n_autofix_workflow` if validation finds issues

## Workflow Management via MCP

Use the n8n MCP tools for all workflow operations:

| Task                    | Tool                            |
|-------------------------|---------------------------------|
| List workflows          | `n8n_list_workflows`            |
| Get workflow details    | `n8n_get_workflow`              |
| Create new workflow     | `n8n_create_workflow`           |
| Update (partial)        | `n8n_update_partial_workflow`   |
| Update (full replace)   | `n8n_update_full_workflow`      |
| Validate                | `n8n_validate_workflow`         |
| Auto-fix issues         | `n8n_autofix_workflow`          |
| Check executions        | `n8n_executions`                |
| Test workflow           | `n8n_test_workflow`             |
| Version history         | `n8n_workflow_versions`         |
| Delete workflow         | `n8n_delete_workflow`           |
| Deploy from template    | `n8n_deploy_template`           |

## Critical Rules

### NEVER edit production workflows directly
- Always copy a `[PROD]` workflow first.
- Make changes on the copy (prefix it `[DEV]` or `[STAGING]`).
- Validate and test the copy.
- Only then update the production workflow using `n8n_update_partial_workflow`.

### Always validate before deploying
- Run `n8n_validate_workflow` on every workflow before activation.
- Fix all errors. Warnings should be reviewed but may be acceptable.

### Use partial updates to save tokens
- Prefer `n8n_update_partial_workflow` over `n8n_update_full_workflow`.
- Partial updates save 80-90% of tokens by sending only changed nodes.

### Use version history for safety
- Call `n8n_workflow_versions` before making changes to note the current version.
- This enables rollback if something goes wrong.

## Expression and Code Syntax

### Expressions (in node parameter fields)
```
={{ $json.body.fieldName }}
={{ $('Previous Node').item.json.value }}
={{ $now.toISO() }}
```
- Always start with `=`
- Wrap in `{{ }}`

### Code Nodes (JavaScript)
```javascript
const items = $input.all();
const results = items.map(item => ({
  action: item.json.body.action,
  timestamp: new Date().toISOString()
}));
return results.map(r => ({ json: r }));
```
- No `={{ }}` braces — this is plain JavaScript.
- Must return an array of objects with a `json` property: `[{json: {...}}]`

### Webhook Data Access
- Incoming webhook data is at `$json.body`, NOT `$json`.
- Query parameters: `$json.query`
- Headers: `$json.headers`

## File Conventions

- Workflow JSON files go in `workflows/` with kebab-case names.
- Prefix workflow names: `[PROD]`, `[STAGING]`, `[DEV]`, `[TEMPLATE]`.
- Back up workflows before major changes: `./scripts/backup-workflows.sh`

## Deployment

```bash
# Deploy a new workflow
./scripts/deploy-workflow.sh workflows/my-workflow.json

# Update an existing workflow
./scripts/deploy-workflow.sh workflows/my-workflow.json <workflow-id>

# Back up all workflows first
./scripts/backup-workflows.sh
```
