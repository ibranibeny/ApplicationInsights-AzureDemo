# Contract: Azure CLI Instruction Path

**Feature**: `001-appinsights-demo` | **Path type**: `cli` | **Date**: 2026-06-22

This contract defines the externally observable behavior of the **Azure CLI**
instruction path. It is the constitution's Infrastructure-as-Code source of truth.
Parameter names below were **confirmed** by reading the vendored
`azure-monitor-demo/infra/main.json` and `main.parameters.json`. Placeholders in
`<angle brackets>` are operator-supplied values.

Confirmed template parameters: `environmentName` (default `demo-monitor`), `location`,
`administratorLogin` (default `demoAdmin`), `administratorPassword` (securestring, **no
default** — supply at deploy time). Auto-generated resource names use
`resourceToken = uniqueString(...)`: web app `app-<token>`, App Insights
`appi-<token>`, Log Analytics `log-<token>`, SQL `sql-<token>`/`sqldb-<token>`,
storage `st<token>`, functions `func-load-<token>`, plan `asp-<token>`.

## Preconditions

- Azure CLI installed; PowerShell 5.1+ available.
- Application Insights extension present: `az extension add -n application-insights`.
- Authenticated and correct subscription selected:
  - `az login`
  - `az account set --subscription "<subscription>"`

## Contract: Deploy

| # | Step (command intent) | Expected result |
|---|------------------------|-----------------|
| 1 | `az group create --name <rg> --location <region>` | Resource group exists (idempotent). |
| 2 | `az deployment group create --resource-group <rg> --template-file azure-monitor-demo/infra/main.json --parameters azure-monitor-demo/infra/main.parameters.json --parameters administratorPassword=<sql-pwd>` | All demo resources created; deployment reports `Succeeded`. |
| 3 | `az monitor app-insights component show --resource-group <rg> --app appi-<token>` | Returns JSON containing `connectionString`. |
| 4 | App Insights connection string **auto-wired by the ARM template** into the web app settings (`APPLICATIONINSIGHTS_CONNECTION_STRING`) | Web app instrumented on first boot; no secret committed to the repo. |

**Idempotency contract**: Re-running steps 1–2 with identical parameters produces no
duplicate resources and reports success (SC-004).

## Contract: Demo (generate load + observe)

| # | Step | Expected result |
|---|------|-----------------|
| 1 | Run the upstream traffic generator (`scripts/generate-traffic.ps1 -AppUrl <webapp-url>`) | ~30 HTTP requests hit the real `/api/*` endpoints. |
| 2 | Open Application Insights → Live Metrics | Requests/telemetry appear in near real time (SC-003). |
| 3 | Open Application Map / Failures / Logs | Dependencies (SQL), exceptions, and requests are visible. |

## Contract: Teardown

| # | Step | Expected result |
|---|------|-----------------|
| 1 | `az group delete --name <rg> --yes --no-wait` | All demo-created resources removed (SC-005). |

## Error / edge behavior

- Unauthenticated or wrong subscription → instructions direct the operator to
  `az login` / `az account set` before any create step.
- Name collision → ARM incremental deployment reuses matching resources; otherwise a
  clear error is surfaced (no partial silent state).
- Region without a required SKU → deployment error surfaced; instructions note
  supported regions.
- No telemetry within ~5 min → verification step: confirm
  `APPLICATIONINSIGHTS_CONNECTION_STRING` app setting and re-run traffic generator.
