# Phase 0 Research: Azure Monitor & Application Insights Demo (CLI + Azure Portal)

**Feature**: `001-appinsights-demo` | **Date**: 2026-06-22

This document resolves the unknowns from the Technical Context and records grounded
decisions. Two primary sources were consulted:

1. The upstream repository `mhuescar/azure-monitor-demo` (README fetched 2026-06-22).
2. Official Microsoft Learn documentation (Application Insights — create/configure,
   connection strings).

> Honesty note (Constitution III): The planning-phase details below originally came
> from the repo's README only. During implementation the repo was vendored and the
> ARM template (`infra/main.json`), parameters (`infra/main.parameters.json`), and
> `scripts/deploy.ps1` were opened file-by-file. **Confirmed facts and corrections to
> the earlier README-based assumptions are recorded in the "Confirmed facts" section
> below**, which supersedes any conflicting statement above it.

## Decision 1 — Adopt the upstream repo by cloning/vendoring it as a subfolder

- **Decision**: Bring `mhuescar/azure-monitor-demo` into the workspace as a vendored
  subfolder (`azure-monitor-demo/`), preserving its MIT LICENSE and attribution. The
  feature's new instructions live in a separate `docs/cli` and `docs/portal`.
- **Rationale**: Keeps upstream code intact and clearly attributed (Principle III),
  while isolating our additions so consistency between the two paths is auditable.
- **Alternatives considered**:
  - Git submodule — rejected for demo simplicity (presenters get one clone; no
    submodule init friction). Revisit if upstream updates must be tracked.
  - Rewrite from scratch — rejected; contradicts the explicit instruction to adopt
    the upstream project.

## Decision 2 — CLI path uses `az` to deploy the upstream ARM template

- **Decision**: The CLI instruction path provisions resources with
  `az deployment group create --template-file infra/main.json --parameters
  infra/main.parameters.json`, after `az group create`. Application Insights specifics
  use the `application-insights` CLI extension.
- **Rationale**: The upstream IaC is ARM (`infra/main.json`), not Bicep. Deploying it
  through `az` honors Principle II (scripted, idempotent — ARM deployments are
  incremental by default) and reuses the proven template rather than reinventing it.
- **Microsoft Learn grounding**:
  - The Application Insights CLI commands require the extension:
    `az extension add -n application-insights`.
  - Create a workspace-based resource:
    `az monitor app-insights component create`.
  - Retrieve the connection string:
    `az monitor app-insights component show` → read the `connectionString` field.
  - If no Log Analytics workspace is supplied at creation, one is created
    automatically (workspace-based is the current standard).
- **Alternatives considered**:
  - Pure imperative `az` resource-by-resource creation — rejected as the primary path
    (more drift risk vs. the upstream template), but documented as a fallback for
    teaching individual commands.
  - `az deployment sub create` — unnecessary; resource-group scope is sufficient.

## Decision 3 — Portal path mirrors the same resource design, step by step

- **Decision**: The portal instruction path documents creating the resource group,
  Log Analytics workspace, Application Insights resource, App Service + plan, SQL
  Database, Storage Account, and Functions app through the Azure portal, then wiring
  the App Insights connection string into the web app settings.
- **Rationale**: Satisfies FR-004/FR-012 (equivalent outcome, kept consistent). The
  portal path is explicitly the documented alternative, never the source of truth
  (Principle II).
- **Microsoft Learn grounding**:
  - Portal creation: **Create a resource → Monitoring & Diagnostics → Application
    Insights → Review + create**.
  - Connection string: **App Insights resource → Overview → Essentials → Connection
    string** (copy to clipboard).
- **Alternatives considered**:
  - Portal path that only creates App Insights (relying on CLI for the rest) —
    rejected; breaks the "equivalent environment via portal only" requirement (US2).

## Decision 4 — Connection string injection, never committed

- **Decision**: The App Insights connection string is read at runtime from App
  Service application settings (`APPLICATIONINSIGHTS_CONNECTION_STRING`) / environment
  variables, populated during deployment. No keys or connection strings are committed;
  `.env.example` from upstream is the template, real values stay local or in Key Vault.
- **Rationale**: Constitution Principle V and FR-007. Aligns with Microsoft Learn
  guidance to set the connection string via configuration/environment.
- **Alternatives considered**:
  - Hardcoding in app config files — rejected (secret leakage).
  - Instrumentation key (legacy) — rejected; connection strings are the current,
    required mechanism.

## Decision 5 — Teardown via resource-group deletion + portal deletion steps

- **Decision**: CLI teardown is `az group delete --name <rg> --yes --no-wait`; the
  portal path documents deleting the resource group from the portal.
- **Rationale**: Single-step, complete teardown (Principle IV, FR-006). Matches the
  upstream README's documented cleanup.

## Decision 6 — Cost-bearing resources are enumerated for cleanup

- **Decision**: quickstart.md lists every cost-bearing resource (App Service B1, SQL
  Basic, Storage, Functions, App Insights ingestion, Log Analytics) with the upstream
  README's ~$0.76/day estimate as a reference, flagged as approximate.
- **Rationale**: FR-009 / SC-006 / Principle IV.
- **Honesty note**: The cost figure is the upstream author's estimate, not an
  independently verified or current price. It will be labeled as such.

## Resolved unknowns

| Technical Context item | Resolution |
|------------------------|------------|
| IaC technology | ARM templates (upstream), deployed via `az deployment group create` |
| Sample app stack | **.NET** web app (`src/web`) is the deployed app (see correction below); Node variants (`src/web-node`, `src/webapp-simple`) exist but are not what `deploy.ps1` ships; load generator is a **.NET-isolated** Functions app (`src/loadtest`) |
| Resource set | RG, Log Analytics, App Insights, App Service (B1 Windows), SQL (Basic), Storage, Functions |
| Connection-string handling | Auto-wired by the ARM template into app settings; never committed |
| Teardown | `az group delete` (CLI) / delete resource group (portal) |
| App Insights CLI prerequisite | `az extension add -n application-insights` |

## Confirmed facts (verified by reading vendored files)

Source files read: `azure-monitor-demo/infra/main.json`,
`azure-monitor-demo/infra/main.parameters.json`,
`azure-monitor-demo/scripts/deploy.ps1`,
`azure-monitor-demo/scripts/generate-traffic.ps1`.

**ARM template (`infra/main.json`)** — creates, in one resource group:
- Log Analytics workspace (`Microsoft.OperationalInsights/workspaces`, PerGB2018,
  30-day retention) — the template **creates** it (no pre-existing workspace needed).
- Application Insights (`Microsoft.Insights/components`, kind web) — **workspace-based**,
  linked to the workspace above.
- Storage account (Standard_LRS, StorageV2).
- SQL Server + Basic database (5 DTU, 1 GB).
- App Service plan **B1, Windows** (`reserved: false`).
- Web App with SystemAssigned identity; app setting
  `APPLICATIONINSIGHTS_CONNECTION_STRING` is **auto-populated by the template** via a
  `reference()` to the App Insights component (no manual wiring needed on the CLI path).
- Functions app (`dotnet-isolated`, `FUNCTIONS_EXTENSION_VERSION ~4`) as the load
  generator (runs every 5 minutes).
- Two metric alerts: High Response Time (> 5000 ms), High Error Rate (> 10%).

**ARM parameters** (`infra/main.json`): `environmentName` (default `demo-monitor`),
`location` (default = resource-group location), `administratorLogin` (default
`demoAdmin`), `administratorPassword` (securestring, **no default** → must be supplied
at deploy time). Resource names derive from
`resourceToken = toLower(uniqueString(...))`: `app-<token>`, `appi-<token>`,
`log-<token>`, `sql-<token>`, `sqldb-<token>`, `st<token>`, `func-load-<token>`,
`asp-<token>`.

**Corrections to earlier README-based assumptions (honesty, Constitution III):**
1. *App stack*: The earlier note assumed **Node.js/Express was the primary deployed
   app**. `scripts/deploy.ps1` actually runs `dotnet publish` on **`src/web` (.NET)**
   and deploys that. Corrected throughout the docs.
2. *Endpoints*: The README listed `/error`, `/load`, `/memory`, `/dependencies`. The
   actual app + `generate-traffic.ps1` use `/api/health`, `/api/products`,
   `/api/simulate-error`, `/api/load-test`, `/api/memory-test`. Corrected throughout.
3. *Log Analytics*: Confirmed the template creates the workspace (previously an open
   question).
4. *App Service OS*: **Windows** B1 (previously open).
5. *deploy.ps1*: It **does** wrap the ARM deployment (`az deployment group create`) and
   also builds/zips/deploys the app and function, so the CLI docs reference it as the
   one-shot option.

**Security finding (remediated):** `infra/main.parameters.json` shipped a hardcoded SQL
password (`Demo123456!`). This violates Constitution V / FR-007. The value was removed
from the vendored file during adoption; the password must now be supplied at deploy
time. A root `.gitignore` was added to exclude `.env` and local parameter files.

**Verification limitation (honesty):** No live Azure subscription was available to the
authoring tooling, so the deploy/verify/teardown commands were **not executed
end-to-end**. They are derived directly from the vendored template and scripts. Tasks
T014, T019, T024 (live-run verification) remain to be performed by a presenter in a
real subscription.

## Best-practice validation against Microsoft Learn (T028)

Validated 2026-06-22 via Microsoft Learn search. The encoded practices are confirmed:

- **Use connection strings, not instrumentation keys.** "We recommend that you use
  connection strings instead of instrumentation keys" and new Azure regions *require*
  them. Source: [Application Insights FAQ](https://learn.microsoft.com/azure/azure-monitor/app/application-insights-faq#do-new-azure-regions-require-the-use-of-connection-strings).
- **Configure via `APPLICATIONINSIGHTS_CONNECTION_STRING` app setting / env var.**
  Source: [Connection strings in Application Insights](https://learn.microsoft.com/azure/azure-monitor/app/connection-strings)
  and [App settings reference for Azure Functions](https://learn.microsoft.com/azure/azure-monitor/app/connection-strings).
- **CLI retrieval matches our docs**: `az monitor app-insights component show
  --resource-group <rg> --app <name>` → read the `connectionString` field. Source:
  [Create and configure Application Insights resources](https://learn.microsoft.com/azure/azure-monitor/app/create-workspace-resource#configure-monitoring).
- **Workspace-based resources are the current standard** (the template creates one).
  Source: [Create a workspace-based Application Insights resource](https://learn.microsoft.com/azure/azure-monitor/app/create-workspace-resource).

> Nuance (honesty): Microsoft notes the instrumentation key inside a connection string
> "aren't security tokens or security keys, and aren't considered secrets." We still
> keep it out of source as good hygiene (injected at runtime), but it is not a
> credential. The genuine secret in this demo is the **SQL admin password**, which is
> what the `.gitignore` + parameter-removal remediation protects.
