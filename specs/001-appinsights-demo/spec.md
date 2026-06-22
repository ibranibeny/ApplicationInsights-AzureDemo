# Feature Specification: Azure Monitor & Application Insights Demo (CLI + Azure Portal)

**Feature Branch**: `001-appinsights-demo`

**Created**: 2026-06-22

**Status**: Draft

**Input**: User description: "from constitution, adding the instruction with cli and azure web portal"

## User Scenarios & Testing *(mandatory)*

This feature delivers a presentation-ready Azure Monitor and Application Insights
demo environment (adopting the upstream `mhuescar/azure-monitor-demo` project) that a
presenter can stand up, demonstrate, and tear down. Building on the project
constitution, it adds **two parallel sets of setup instructions** for every demo
step: one driven by the **Azure CLI** (scripted) and one driven by the **Azure web
portal** (manual click-through). A presenter may choose either path and reach the
same working result.

### User Story 1 - Deploy the demo with the Azure CLI (Priority: P1)

A presenter with an Azure subscription runs a small set of scripted, parameterized
commands to provision the complete demo environment (resource group, Log Analytics
workspace, Application Insights resource, and the sample workload) and confirms that
real telemetry is flowing.

**Why this priority**: This is the core value of the demo and the constitution's
non-negotiable "Infrastructure as Code" path. It must work end-to-end before any
other instruction set matters.

**Independent Test**: Can be fully tested by running the CLI deployment against a
real subscription and verifying that the Application Insights resource receives live
telemetry within minutes — delivering a complete, demonstrable environment on its own.

**Acceptance Scenarios**:

1. **Given** an authenticated Azure session and required parameters (subscription,
   resource group, region, naming prefix), **When** the presenter runs the CLI
   deployment, **Then** all demo resources are created and the command reports
   success with the created resource names.
2. **Given** the deployment has already been run once, **When** the presenter runs
   it again with the same parameters, **Then** it completes without error and does
   not create duplicate resources (idempotent).
3. **Given** the environment is deployed, **When** the presenter opens the
   Application Insights resource, **Then** live telemetry (requests, traces,
   metrics) from the sample workload is visible.

---

### User Story 2 - Set up the demo via the Azure web portal (Priority: P2)

A presenter who prefers a visual walkthrough follows step-by-step Azure portal
instructions to create the same resources and connect the sample workload, reaching
the same working demo without using the command line.

**Why this priority**: Adds an accessible, click-through path for audiences and
presenters who want to see the portal experience, but depends on the same resource
design proven by the P1 CLI path.

**Independent Test**: Can be tested by following only the portal instructions in a
clean subscription and confirming the resulting environment matches the CLI outcome
(same resource types, same live telemetry).

**Acceptance Scenarios**:

1. **Given** the portal instructions, **When** the presenter follows them step by
   step, **Then** they create a resource group, Log Analytics workspace, and
   Application Insights resource matching the CLI-produced environment.
2. **Given** the portal-created Application Insights resource, **When** the sample
   workload is connected using the documented connection string, **Then** live
   telemetry appears in the portal.
3. **Given** a step in the portal instructions, **When** the presenter reads it,
   **Then** it names the exact blade/option to click and the value to enter, with
   no undocumented assumptions.

---

### User Story 3 - Demonstrate observability and tear down (Priority: P3)

After deployment, the presenter generates representative load against the sample
workload, walks through key Azure Monitor / Application Insights experiences
(Live Metrics, Application Map, transaction search, dashboards/workbooks), and then
removes all created resources with a single teardown step.

**Why this priority**: Completes the storytelling and enforces the constitution's
"Reproducible Teardown & Cost Control" principle, but requires a deployed
environment first.

**Independent Test**: Can be tested by running the load generator, confirming the
demonstrated views populate with data, then running teardown and confirming no
demo resources remain.

**Acceptance Scenarios**:

1. **Given** a deployed environment, **When** the presenter triggers sample load,
   **Then** Live Metrics and the Application Map reflect the activity in near real
   time.
2. **Given** the demo is finished, **When** the presenter runs the teardown step
   (CLI) or follows the portal deletion instructions, **Then** all resources
   created for the demo are removed and the cost-bearing resources are gone.

### Edge Cases

- What happens when the chosen resource names already exist in the subscription?
  The deployment must either reuse them idempotently or fail with a clear,
  actionable message rather than producing a partial environment.
- How does the system handle an unauthenticated or wrong-subscription session?
  Instructions must direct the presenter to authenticate and select the correct
  subscription before any resource is created.
- What happens when the selected region does not offer a required resource?
  Instructions must call out supported regions or surface the error clearly.
- What happens if telemetry does not appear within the expected few minutes?
  Guidance must include a basic verification/troubleshooting step.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The demo MUST adopt the upstream `mhuescar/azure-monitor-demo` project,
  with clear attribution and any modifications documented.
- **FR-002**: The demo MUST provide an Azure CLI deployment path that provisions the
  full environment (resource group, Log Analytics workspace, Application Insights
  resource, and sample workload).
- **FR-003**: The CLI deployment MUST be idempotent and parameterized for at least
  subscription, resource group, region, and a resource naming prefix.
- **FR-004**: The demo MUST provide an Azure web portal instruction set that produces
  an environment equivalent to the CLI path, with explicit, step-by-step guidance.
- **FR-005**: Both instruction paths MUST result in the sample workload emitting real
  Application Insights telemetry (requests, traces, metrics) that is visible within
  minutes.
- **FR-006**: The demo MUST provide a teardown path (CLI command and portal deletion
  instructions) that removes all resources it created.
- **FR-007**: Instructions and scripts MUST NOT contain committed secrets;
  connection strings and keys MUST be injected via parameters, environment variables,
  or Key Vault references and read at runtime.
- **FR-008**: Both paths MUST instruct the presenter to authenticate and confirm the
  target subscription before creating resources.
- **FR-009**: Documentation MUST list every cost-bearing resource so it can be
  deleted after the presentation.
- **FR-010**: Best-practice guidance encoded in the instructions MUST be validated
  against official Microsoft Learn documentation.
- **FR-011**: The demo MUST include a way to generate representative sample load so
  the observability experiences populate with data during a presentation.
- **FR-012**: The two instruction paths MUST be kept consistent: a change to the
  resource design MUST be reflected in both the CLI and portal instructions.

### Key Entities *(include if feature involves data)*

- **Demo Environment**: The complete set of Azure resources provisioned for one
  presentation, identified by a resource naming prefix and region.
- **Resource Group**: The container that holds all demo resources and enables a
  single-step teardown.
- **Log Analytics Workspace**: The backing store for Azure Monitor logs used by the
  Application Insights resource.
- **Application Insights Resource**: The telemetry endpoint that receives traces,
  metrics, and logs from the sample workload; exposes the connection string used by
  the workload.
- **Sample Workload**: The instrumented application (from the upstream demo) that
  generates real telemetry.
- **Supporting Resources**: Additional Azure resources provisioned by the upstream
  demo to make telemetry realistic — an App Service (+ plan) that hosts the sample
  workload, an Azure SQL Database and Storage Account the workload calls (producing
  dependency telemetry), and an Azure Functions load generator. These are
  cost-bearing and MUST be included in cleanup documentation (see FR-009, SC-006).
- **Instruction Set**: A documented sequence of steps for one path (CLI or portal)
  to deploy, demonstrate, or tear down the environment.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A presenter can deploy the full demo environment via the CLI path in
  under 15 minutes from an authenticated session.
- **SC-002**: A presenter following only the Azure portal instructions reaches an
  environment functionally equivalent to the CLI path (same resource types and live
  telemetry) without needing the command line.
- **SC-003**: Live Application Insights telemetry from the sample workload is visible
  within 5 minutes of completing either deployment path.
- **SC-004**: Re-running the CLI deployment with the same parameters produces no
  duplicate resources and reports success (idempotency verified).
- **SC-005**: Running the teardown leaves zero demo-created resources in the target
  resource group.
- **SC-006**: 100% of cost-bearing resources are listed in the documentation for
  post-demo cleanup.

## Assumptions

- The presenter has an active Azure subscription with permission to create the
  required resources.
- Azure CLI is used as the primary scripted path, invoked from PowerShell scripts as
  established by the project constitution; the portal path is an alternative for the
  same outcome.
- The sample workload and demo content come from the upstream
  `mhuescar/azure-monitor-demo` repository and are used as-is unless documented
  otherwise.
- Lowest-tier SKUs that still demonstrate the features are preferred, per the
  constitution's cost-control principle.
- Demo environments are ephemeral and expected to be torn down after each
  presentation.
