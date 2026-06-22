# Implementation Plan: Azure Monitor & Application Insights Demo (CLI + Azure Portal)

**Branch**: `001-appinsights-demo` | **Date**: 2026-06-22 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-appinsights-demo/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Deliver a presentation-ready Azure Monitor & Application Insights demo by adopting the
upstream `mhuescar/azure-monitor-demo` project and adding **two parallel, equivalent
instruction paths** for deploy / demo / teardown: an **Azure CLI** path (scripted,
parameterized, idempotent, invoked from PowerShell per the constitution) and an
**Azure web portal** path (explicit click-through). The upstream demo provisions an
App Service (Node.js/Express app), Application Insights (workspace-based), a Log
Analytics workspace, plus supporting SQL Database, Storage Account, and an Azure
Functions load generator. Both instruction paths MUST produce an equivalent
environment with real telemetry flowing, and a matching teardown.

## Technical Context

**Language/Version**: PowerShell 5.1+ (deployment/teardown automation); Node.js 18+
(upstream Express sample app); optional .NET 8 (upstream alternative app); JavaScript
(upstream load/test endpoints).

**Primary Dependencies**: Azure CLI (`az`) with the `application-insights` extension
(`az extension add -n application-insights`); upstream ARM templates
(`infra/main.json`, `infra/main.parameters.json`); Azure Monitor / Application
Insights; upstream PowerShell scripts (`scripts/deploy.ps1`, `demo-final.ps1`,
`generate-traffic.ps1`).

**Storage**: Azure SQL Database (Basic) and Azure Storage Account as provisioned by
the upstream demo; Log Analytics workspace as the backing store for Application
Insights telemetry. No new application data model is introduced by this feature.

**Testing**: Manual verification of a full deploy → demo → teardown cycle against a
real Azure subscription (per constitution Principle II/IV). Idempotency verified by
re-running the CLI deployment. Telemetry presence verified in Application Insights
(Live Metrics / Logs).

**Target Platform**: Azure (App Service hosting the Node.js app, Application Insights,
Log Analytics, SQL, Storage, Functions). Operator runs from a workstation with Azure
CLI + PowerShell.

**Project Type**: Demo/documentation feature over an adopted IaC repository — the
deliverable is the adopted upstream code plus two new equivalent instruction sets
(CLI and portal) and validation, not a new application.

**Performance Goals**: CLI deploy completes in under ~15 minutes (SC-001); telemetry
visible within ~5 minutes of either path (SC-003). These are demo-experience targets,
not production SLAs.

**Constraints**: No committed secrets — connection strings/keys injected at runtime
(constitution Principle V, FR-007). Lowest-tier SKUs that still demonstrate features
(B1 App Service, Basic SQL). Both instruction paths kept consistent (FR-012). Best
practices validated against Microsoft Learn (FR-010).

**Scale/Scope**: Single ephemeral demo environment per presenter, one resource group,
~6 Azure resource types. Parameterized for subscription, resource group, region, and
naming prefix.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Demo-First, Presentation-Ready | End-to-end reproducible deploy/demo/teardown; no undocumented manual steps | PASS — both paths cover deploy, demo, and teardown |
| II. Infrastructure as Code (NON-NEGOTIABLE) | Scripted `az`/PowerShell deployment; idempotent; parameterized (sub, RG, region, naming) | PASS — CLI path wraps ARM deployment via `az`, parameterized; portal path is the documented alternative, not the source of truth |
| III. Honesty & Source Fidelity | Upstream attributed; modifications documented; no fabricated telemetry | PASS — upstream `mhuescar/azure-monitor-demo` (MIT) attributed; real telemetry only |
| IV. Reproducible Teardown & Cost Control | Matching teardown; lowest-tier SKUs; cost-bearing resources listed | PASS — `az group delete` teardown + portal deletion steps; B1/Basic SKUs; cost list in quickstart |
| V. Observability of the Demo Itself | Sample workload genuinely instrumented; secrets injected, never committed | PASS — connection string injected via app settings/env; no secrets in repo |

**Result**: PASS. No violations to justify (Complexity Tracking left empty).

## Project Structure

### Documentation (this feature)

```text
specs/001-appinsights-demo/
├── plan.md              # This file (/speckit.plan command output)
├── spec.md              # Feature specification
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── cli-deployment.md      # CLI instruction-path contract (commands + expected results)
│   └── portal-deployment.md   # Portal instruction-path contract (steps + expected results)
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

The upstream `mhuescar/azure-monitor-demo` repository is adopted into the workspace.
This feature adds equivalent CLI and portal instruction sets and a consistency
mapping; it does not introduce a new application codebase.

```text
azure-monitor-demo/            # Adopted upstream (cloned/vendored), attributed (MIT)
├── infra/
│   ├── main.json              # ARM template (resources)
│   └── main.parameters.json   # Parameters (subscription/RG/region/naming)
├── src/
│   ├── webapp-simple/         # Node.js + Express app with Application Insights
│   ├── web/                   # .NET alternative app
│   └── loadtest/              # Azure Functions load generator
├── scripts/
│   ├── deploy.ps1             # Upstream PowerShell deploy
│   ├── demo-final.ps1         # Upstream demo/traffic
│   └── generate-traffic.ps1   # Upstream traffic generator
└── docs/                      # Upstream docs

docs/                          # THIS feature's added instruction sets
├── cli/
│   └── README.md              # Azure CLI deploy / demo / teardown (PowerShell-invoked)
└── portal/
    └── README.md              # Azure portal step-by-step deploy / demo / teardown
```

**Structure Decision**: Adopt the upstream repo as-is (Principle III) and add a
feature-level `docs/cli` and `docs/portal` instruction set that map 1:1 to the same
resource design. The CLI path is the constitution's IaC source of truth; the portal
path is a documented equivalent. The exact vendoring location (subfolder vs. submodule
vs. clone) is finalized in research.md.

## Complexity Tracking

> No constitution violations. Section intentionally empty.
