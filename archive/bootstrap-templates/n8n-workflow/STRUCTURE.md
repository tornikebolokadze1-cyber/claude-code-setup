# n8n Workflow Project Structure

This project contains n8n workflow definitions, deployment scripts, and documentation
for managing automation workflows on an n8n instance.

## Directory Layout

```
.
├── CLAUDE.md                 # AI assistant rules for this project
├── STRUCTURE.md              # This file — project structure overview
├── .env.example              # Environment variable template
├── workflows/                # n8n workflow JSON exports
│   ├── README.md             # Import/export and management guide
│   └── *.json                # Individual workflow files
├── docs/                     # Project documentation
│   ├── architecture.md       # Workflow connections and data flow
│   └── credentials-setup.md  # Credential configuration guide
└── scripts/                  # Automation scripts
    ├── deploy-workflow.sh    # Deploy a workflow JSON to n8n
    └── backup-workflows.sh   # Back up all workflows from n8n
```

## Conventions

### Workflow Files

- Each workflow lives in its own JSON file under `workflows/`.
- File names use kebab-case and describe the workflow purpose:
  `order-processing.json`, `slack-notifications.json`, `daily-report.json`.
- Workflow JSON files are exported directly from n8n (Settings > Export).
- Never hand-edit workflow JSON unless you fully understand the node schema.

### Naming Workflows in n8n

Use a consistent prefix scheme so workflows are easy to find:

| Prefix       | Purpose                        |
|--------------|--------------------------------|
| `[PROD]`     | Production workflows           |
| `[STAGING]`  | Staging / test copies          |
| `[DEV]`      | Development drafts             |
| `[TEMPLATE]` | Reusable templates             |

### Tags

Apply n8n tags to group related workflows: `webhook`, `scheduled`, `integration`,
`internal`, `customer-facing`, etc.

## Workflow Lifecycle

1. **Develop** — Build or modify a workflow in the n8n editor (use a `[DEV]` copy).
2. **Export** — Download the JSON and commit it to `workflows/`.
3. **Review** — Validate the workflow with `n8n_validate_workflow`.
4. **Deploy** — Use `scripts/deploy-workflow.sh` or `n8n_create_workflow` / `n8n_update_partial_workflow`.
5. **Monitor** — Check executions via the n8n UI or `n8n_executions`.
6. **Back up** — Run `scripts/backup-workflows.sh` periodically or before major changes.
