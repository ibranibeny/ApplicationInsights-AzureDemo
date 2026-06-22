# Phase 1 Data Model: Azure Monitor & Application Insights Demo

**Feature**: `001-appinsights-demo` | **Date**: 2026-06-22

This feature provisions Azure resources and authors instruction sets; it does not
introduce a new application database schema. The "entities" below are the demo's
infrastructure resources and documentation artifacts, with their key attributes,
relationships, and the states they pass through during a presentation.

## Entities

### Demo Environment

The complete set of Azure resources for one presentation.

- **Attributes**: naming prefix, region, subscription ID, resource group name.
- **Relationships**: contains exactly one Resource Group, which contains all other
  resources.
- **States**: `not-deployed` → `deploying` → `deployed` → `tearing-down` →
  `removed`.

### Resource Group

Container enabling single-step teardown.

- **Attributes**: name, region, tags (e.g., `purpose=demo`).
- **Relationships**: parent of all resources below.
- **Validation**: name unique within the subscription; if it already exists,
  deployment reuses it idempotently or fails with a clear message (edge case).

### Log Analytics Workspace

Backing store for Azure Monitor / Application Insights logs.

- **Attributes**: name, region, retention.
- **Relationships**: linked to the Application Insights Resource (workspace-based).
- **Validation**: if not supplied at App Insights creation, one is created
  automatically.

### Application Insights Resource (workspace-based)

Telemetry endpoint for the sample workload.

- **Attributes**: name, region, **connection string** (sensitive — not committed),
  linked workspace ID.
- **Relationships**: receives telemetry from the Sample Workload; linked to the Log
  Analytics Workspace.
- **Validation**: requires the `application-insights` CLI extension for CLI
  management; connection string injected into the workload at runtime.

### App Service (+ Plan)

Hosts the Node.js/Express sample app.

- **Attributes**: app name, plan SKU (B1), runtime (Node.js), app settings
  (`APPLICATIONINSIGHTS_CONNECTION_STRING`).
- **Relationships**: runs the Sample Workload; references the App Insights connection
  string via app settings.

### Sample Workload

The instrumented upstream application generating real telemetry.

- **Attributes**: endpoints (`/`, `/health`, `/api/products`, `/error`, `/load`,
  `/memory`, `/dependencies`), custom events, custom metrics.
- **Relationships**: emits requests/traces/metrics/exceptions to the App Insights
  Resource.
- **States**: `idle` → `under-load` (when the load generator runs).

### Supporting Resources (SQL Database, Storage Account, Functions load generator)

Provisioned by the upstream demo to make telemetry realistic.

- **Attributes**: SQL (Basic SKU), Storage (standard), Functions app (load/traffic).
- **Relationships**: SQL/Storage are dependencies the app calls (dependency
  telemetry); the Functions app drives synthetic traffic.

### Instruction Set

A documented sequence of steps for one path.

- **Attributes**: path type (`cli` | `portal`), phase (`deploy` | `demo` |
  `teardown`), ordered steps, expected results.
- **Relationships**: the `cli` and `portal` instruction sets MUST map 1:1 to the same
  resource design (FR-012). A change to the resource design updates both.

## State Transitions (presentation lifecycle)

```text
not-deployed → (deploy: CLI or portal) → deployed
deployed → (generate load) → workload under-load → (telemetry visible)
deployed → (teardown: az group delete / portal delete) → removed
```

## Notes

- The only sensitive attribute is the Application Insights **connection string**; it is
  never committed and is injected at runtime (FR-007, Constitution V).
- No relational schema, migrations, or persistence logic is authored by this feature.
