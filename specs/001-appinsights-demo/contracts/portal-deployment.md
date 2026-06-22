# Contract: Azure Web Portal Instruction Path

**Feature**: `001-appinsights-demo` | **Path type**: `portal` | **Date**: 2026-06-22

This contract defines the externally observable behavior of the **Azure web portal**
instruction path. It is the documented equivalent of the CLI path — never the source
of truth (Constitution II). Every step names the exact blade/option and the value to
enter (FR-004, US2 acceptance scenario 3).

## Preconditions

- Signed in to the Azure portal (`https://portal.azure.com`).
- Correct subscription selected in the portal context.

## Contract: Deploy

| # | Step (portal navigation) | Expected result |
|---|--------------------------|-----------------|
| 1 | **Create a resource → Resource group**; enter `<rg>` and `<region>`; **Review + create** | Resource group exists. |
| 2 | **Create a resource → Monitoring & Diagnostics → Application Insights**; select `<rg>`, `<region>`, name `<appinsights-name>`; **Review + create** | Workspace-based App Insights resource created (Log Analytics workspace auto-created if none chosen). |
| 3 | Create App Service plan (**B1, Windows**) + Web App (**.NET runtime**) in `<rg>` | Web app exists, ready to host the sample `src/web` workload. |
| 4 | Create SQL Database (Basic), Storage Account, and Functions app in `<rg>` | Supporting resources exist, matching the CLI environment. |
| 5 | **App Insights → Overview → Essentials → Connection string** (copy); paste into **Web App → Settings → Environment variables** as `APPLICATIONINSIGHTS_CONNECTION_STRING` | Web app configured; connection string not stored in the repo. |
| 6 | Deploy the sample app code to the web app | App running and instrumented. |

**Equivalence contract**: The resulting environment matches the CLI path — same
resource types and live telemetry (SC-002).

## Contract: Demo (generate load + observe)

| # | Step | Expected result |
|---|------|-----------------|
| 1 | Browse the sample app endpoints (`/api/health`, `/api/products`, `/api/simulate-error`, `/api/load-test`, `/api/memory-test`) | Traffic and errors generated. |
| 2 | **App Insights → Live Metrics** | Activity visible in near real time. |
| 3 | **App Insights → Application Map / Failures / Logs** | Dependencies, exceptions, custom events visible. |

## Contract: Teardown

| # | Step | Expected result |
|---|------|-----------------|
| 1 | **Resource groups → `<rg>` → Delete resource group** (type the name to confirm) | All demo-created resources removed (SC-005). |

## Error / edge behavior

- Wrong subscription → instructions direct switching the portal subscription before
  creating anything.
- Name collision → portal surfaces a validation error; instructions tell the operator
  to choose a different name or reuse.
- Region without a required SKU → portal disables/flags the option; instructions list
  supported regions.
- No telemetry within ~5 min → verification step: confirm the
  `APPLICATIONINSIGHTS_CONNECTION_STRING` app setting and re-generate traffic.
