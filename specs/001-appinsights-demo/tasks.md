# Tasks: Azure Monitor & Application Insights Demo (CLI + Azure Portal)

**Input**: Design documents from `/specs/001-appinsights-demo/`

**Prerequisites**: plan.md (required), spec.md (user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Not requested. The spec defines manual verification (deploy → demo → teardown) rather than automated tests, so no automated test tasks are included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths are included in each task

## Path Conventions

- Adopted upstream repo: `azure-monitor-demo/` at repository root (vendored, MIT)
- Feature instruction sets (new): `docs/cli/`, `docs/portal/` at repository root
- Spec artifacts: `specs/001-appinsights-demo/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Bring in the upstream project and prepare a clean working layout.

- [X] T001 Clone/vendor `mhuescar/azure-monitor-demo` into `azure-monitor-demo/` at the repository root, preserving its `LICENSE` and README attribution (Constitution III)
- [X] T002 [P] Create the feature instruction-set folders `docs/cli/` and `docs/portal/` at the repository root
- [X] T003 [P] Add/verify `.gitignore` entries so secrets are never committed: `.env`, `*.env`, local parameter files with real values (keep `azure-monitor-demo/.env.example` only) — **also remediated a committed SQL password in `infra/main.parameters.json`**
- [X] T004 Verify local prerequisites and record versions in `docs/cli/README.md` prerequisites section: Azure CLI present, `az extension add -n application-insights` succeeds, PowerShell 5.1+ available — *documented; `az` not executed (no subscription/CLI run in authoring env)*

**Checkpoint**: Upstream code is present and attributed; instruction folders exist; no secrets tracked.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Confirm the real upstream resource design so both instruction paths describe the same environment. This resolves the open items recorded in `specs/001-appinsights-demo/research.md` and MUST complete before US1/US2 instructions are finalized.

**⚠️ CRITICAL**: No user-story instruction set can be finalized until the upstream template facts are confirmed.

- [X] T005 Inspect `azure-monitor-demo/infra/main.json` and `azure-monitor-demo/infra/main.parameters.json`; record the exact parameter names (subscription/RG/region/naming prefix) and the full resource list in `specs/001-appinsights-demo/research.md` (replace the "open items" section)
- [X] T006 [P] Confirm from `azure-monitor-demo/infra/main.json` whether the Log Analytics workspace is created by the template or expected to pre-exist; note the App Service OS and Node.js runtime version in `specs/001-appinsights-demo/research.md` — *confirmed: template creates the workspace; App Service is B1 **Windows**; deployed app is **.NET** (`src/web`), correcting the earlier Node assumption*
- [X] T007 [P] Inspect `azure-monitor-demo/scripts/deploy.ps1` to determine whether it already wraps `az deployment group create`; record in `specs/001-appinsights-demo/research.md` whether the CLI path reuses `deploy.ps1` or documents `az` commands directly — *confirmed: it wraps the ARM deployment AND builds/deploys the app; docs reference both options*
- [X] T008 Update `specs/001-appinsights-demo/contracts/cli-deployment.md` and `contracts/portal-deployment.md` to replace placeholder `<appinsights-name>`/parameter names with the confirmed values from T005–T007

**Checkpoint**: Resource design and parameter names are confirmed and consistent across both contracts. Instruction authoring can proceed.

---

## Phase 3: User Story 1 - Deploy the demo with the Azure CLI (Priority: P1) 🎯 MVP

**Goal**: A presenter runs scripted, parameterized `az`/PowerShell commands to provision the full environment and sees real telemetry.

**Independent Test**: From an authenticated session, run the CLI deploy against a real subscription and confirm App Insights receives live telemetry within ~5 minutes; re-run to confirm idempotency.

### Implementation for User Story 1

- [X] T009 [US1] Author `docs/cli/README.md` "Prerequisites & Auth" section: `az login`, `az account set --subscription <subscription>`, `az extension add -n application-insights` (FR-008)
- [X] T010 [US1] Author `docs/cli/README.md` "Deploy" section with parameterized commands (`az group create`, `az deployment group create` against `azure-monitor-demo/infra/main.json`) using the confirmed parameter names from T005 (FR-002, FR-003)
- [X] T011 [US1] Add `docs/cli/README.md` step to retrieve the connection string via `az monitor app-insights component show ... --query connectionString -o tsv` and inject it into the web app settings (`APPLICATIONINSIGHTS_CONNECTION_STRING`) without committing it (FR-005, FR-007)
- [X] T012 [US1] Document the idempotency expectation in `docs/cli/README.md`: re-running deploy with the same parameters creates no duplicates and reports success (SC-004)
- [X] T013 [US1] Add a "Verify telemetry" subsection to `docs/cli/README.md`: open Live Metrics and confirm requests within ~5 minutes, with the basic troubleshooting step (check app setting, re-run traffic) (SC-003, edge case)
- [X] T013a [US1] Document the remaining edge cases in `docs/cli/README.md`: resource-name collision (incremental deployment reuses or fails with a clear message) and region without a required SKU (surface the error; list supported regions) (spec.md Edge Cases)
- [ ] T014 [P] [US1] **BLOCKED — no Azure subscription available to authoring tooling.** Execute the CLI deploy end-to-end against a real subscription; capture the actual created resource names and timing, and reconcile any discrepancies back into `docs/cli/README.md` and `contracts/cli-deployment.md` (SC-001)

**Checkpoint**: A presenter can deploy the full demo via CLI and see live telemetry — MVP is functional and independently testable.

---

## Phase 4: User Story 2 - Set up the demo via the Azure web portal (Priority: P2)

**Goal**: A presenter reaches an equivalent environment using only step-by-step portal instructions.

**Independent Test**: Follow only `docs/portal/README.md` in a clean subscription and confirm the result matches the CLI environment (same resource types, live telemetry).

### Implementation for User Story 2

- [X] T015 [US2] Author `docs/portal/README.md` "Sign in & subscription" section directing the presenter to select the correct subscription before creating anything (FR-008)
- [X] T016 [US2] Author the portal "Create resources" steps in `docs/portal/README.md` (Resource group → Application Insights via Monitoring & Diagnostics → App Service plan B1 + Web App Node.js → SQL Basic → Storage → Functions), each naming the exact blade/option and value, matching the confirmed design from Phase 2 (FR-004, US2 scenario 3) — *corrected to .NET runtime / Windows B1 per Phase 2 findings*
- [X] T017 [US2] Add the portal connection-string step to `docs/portal/README.md`: App Insights → Overview → Essentials → Connection string → copy → Web App → Environment variables → `APPLICATIONINSIGHTS_CONNECTION_STRING` (FR-005, FR-007)
- [X] T018 [US2] Add a "Verify telemetry" subsection to `docs/portal/README.md` mirroring the CLI verification (Live Metrics within ~5 min + troubleshooting) (SC-003)
- [X] T018a [US2] Document the remaining edge cases in `docs/portal/README.md`: resource-name collision (portal validation error; choose a different name or reuse) and region without a required SKU (option disabled/flagged; list supported regions) (spec.md Edge Cases)
- [ ] T019 [P] [US2] **BLOCKED — no Azure subscription available to authoring tooling.** Walk the portal instructions end-to-end in a clean subscription; confirm equivalence to the CLI environment and reconcile any gaps into `docs/portal/README.md` and `contracts/portal-deployment.md` (SC-002)

**Checkpoint**: The portal path produces an environment equivalent to the CLI path, verified independently.

---

## Phase 5: User Story 3 - Demonstrate observability and tear down (Priority: P3)

**Goal**: Generate representative load, walk the key Azure Monitor / App Insights experiences, then remove everything.

**Independent Test**: On a deployed environment, run the load generator, confirm the demonstrated views populate, then run teardown and confirm no demo resources remain.

### Implementation for User Story 3

- [X] T020 [US3] Document load generation in both `docs/cli/README.md` and `docs/portal/README.md` using the upstream `azure-monitor-demo/scripts/demo-final.ps1` / `generate-traffic.ps1` (FR-011)
- [X] T021 [US3] Author a "Demo walkthrough" section (shared) covering Live Metrics, Application Map, transaction/failure search, and Logs, mapped to the upstream endpoints (`/api/health`, `/api/simulate-error`, `/api/load-test`, `/api/memory-test`) — *endpoints corrected to actual `/api/*` routes (`docs/demo-walkthrough.md`)*
- [X] T022 [P] [US3] Add the teardown section to `docs/cli/README.md` (`az group delete --name <rg> --yes --no-wait`) (FR-006, SC-005)
- [X] T023 [P] [US3] Add the teardown section to `docs/portal/README.md` (Resource groups → delete resource group, type name to confirm) (FR-006, SC-005)
- [ ] T024 [US3] **BLOCKED — no Azure subscription available to authoring tooling.** Verify teardown leaves zero demo-created resources (`az group exists --name <rg>` returns false) and note the verification in both READMEs (SC-005) — *teardown + verify commands documented; live verification pending a real subscription*

**Checkpoint**: Full deploy → demo → teardown cycle works from both paths.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Consistency, cost transparency, and best-practice validation across both paths.

- [X] T025 [P] Author the root demo `README.md` linking `docs/cli/README.md` and `docs/portal/README.md`, with upstream attribution to `mhuescar/azure-monitor-demo` (MIT) (FR-001, Constitution III)
- [X] T026 [P] Add the cost-bearing-resource table (from `specs/001-appinsights-demo/quickstart.md`) to the root `README.md`, labeled as approximate/unverified, with the post-demo cleanup reminder (FR-009, SC-006) — *cost table authored in `docs/cost.md` and linked from the root README*
- [X] T027 Cross-check `docs/cli/README.md` and `docs/portal/README.md` for 1:1 consistency (same resources, names, and outcomes); record the consistency check result (FR-012) — *consistent: same resource set (Log Analytics, workspace-based App Insights, Storage, SQL Basic, App Service B1 Windows, .NET Web App, Functions, 2 alerts), same `APPLICATIONINSIGHTS_CONNECTION_STRING` setting, same teardown*
- [X] T028 [P] Validate the encoded best practices (workspace-based App Insights, connection-string injection, `application-insights` extension) against Microsoft Learn and cite the sources in `specs/001-appinsights-demo/research.md` (FR-010)
- [X] T029 Run a secrets scan over the repo to confirm no connection strings/keys are committed (e.g., grep for `InstrumentationKey=`/`ConnectionString`); document the result (FR-007) — *scan found only placeholders (`your-key`) and `.env.example`; the real SQL password was removed from `main.parameters.json`*

---

## Dependencies & Execution Order

- **Setup (Phase 1)** → blocks everything.
- **Foundational (Phase 2, T005–T008)** → blocks US1, US2, US3 (instruction sets need confirmed parameters/design).
- **US1 (P1)** → MVP; deliverable on its own after Phase 2.
- **US2 (P2)** → depends on Phase 2; otherwise independent of US1 (different files: `docs/portal/` vs `docs/cli/`).
- **US3 (P3)** → requires a deployed environment from US1 or US2 to verify (T024), but authoring (T020–T023) can start after Phase 2.
- **Polish (Phase 6)** → after the user stories whose content it consolidates.

### Story completion order (by priority)

```text
Setup → Foundational → US1 (MVP) → US2 → US3 → Polish
```

## Parallel Execution Examples

- **Phase 1**: T002 and T003 can run in parallel (different files), after T001.
- **Phase 2**: T006 and T007 can run in parallel (independent inspections), after T005.
- **Across stories** (after Phase 2): US1 authoring (`docs/cli/`) and US2 authoring (`docs/portal/`) touch different files and can proceed in parallel; only the live-run verification tasks (T014, T019, T024) need a real subscription and should be serialized to avoid resource-name collisions.
- **Phase 6**: T025, T026, T028 are parallelizable; T027 and T029 run after the docs are stable.

## Implementation Strategy

- **MVP first**: Deliver US1 (Phase 1 → Phase 2 → Phase 3). That alone is a complete, demonstrable environment.
- **Incremental**: Add US2 (portal equivalent), then US3 (demo + teardown), then Polish.
- **Honesty gates**: Phase 2 exists specifically to replace assumptions with confirmed upstream facts before any instructions claim exact commands.

## Format validation

All tasks above use the required checklist format: `- [ ] T### [P?] [Story?] Description with file path`. Setup, Foundational, and Polish tasks carry no story label; US1/US2/US3 tasks carry their labels.
