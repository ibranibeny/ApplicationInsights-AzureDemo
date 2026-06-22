# Azure Monitor & Application Insights Demo Constitution

## Core Principles

### I. Demo-First, Presentation-Ready
Every artifact exists to support a live client presentation of Azure Monitor and
Application Insights. Resources, dashboards, and sample telemetry MUST be
reproducible from scratch and tear-downable on demand. No component may depend on
manual, undocumented setup steps; if it cannot be demoed end-to-end, it does not
ship.

### II. Infrastructure as Code (NON-NEGOTIABLE)
All Azure resources MUST be provisioned through scripted, version-controlled
deployment — Azure CLI (`az`) invoked from PowerShell scripts. No portal
click-ops as the source of truth. Every script MUST be idempotent (safe to re-run)
and MUST expose parameters for subscription, resource group, region, and resource
naming. Manual portal changes are allowed only for live demonstration and MUST NOT
be required for the environment to function.

### III. Honesty & Source Fidelity
Adopted upstream content (e.g., `mhuescar/azure-monitor-demo`) MUST be attributed
and used as-is or with clearly documented modifications. Sample data, metrics, and
narrative MUST reflect real Application Insights behavior — no fabricated dashboards
or simulated screenshots presented as live telemetry. When something is mocked or
simulated for the demo, it MUST be labeled as such.

### IV. Reproducible Teardown & Cost Control
Every deployment MUST ship with a matching teardown script that removes all created
resources. Demo environments are ephemeral by default. Resource SKUs MUST favor the
lowest tier that demonstrates the feature, and any resource with ongoing cost MUST
be documented in the README so it can be deleted after the presentation.

### V. Observability of the Demo Itself
The demo MUST instrument its own sample workload with Application Insights so that
traces, metrics, logs, and live metrics are genuinely flowing. Connection strings
and instrumentation keys MUST be injected via configuration/parameters, never
hardcoded or committed. The demo should make the value of observability visible
within minutes of deployment.

## Security & Configuration Constraints

- Secrets (connection strings, instrumentation keys, credentials) MUST NOT be
  committed to the repository. Use parameters, environment variables, or Azure
  Key Vault references.
- Scripts MUST authenticate using the operator's existing `az login` session or a
  documented service principal; no embedded credentials.
- Least-privilege: deployment identities request only the roles needed to create
  the demo resources.
- All resource names and regions MUST be parameterized to avoid collisions across
  multiple presenters.

## Development Workflow

- Tooling baseline: Azure CLI (`az`) + PowerShell for all provisioning and teardown.
- Best practices MUST be validated against official Microsoft Learn documentation
  before being encoded into scripts.
- Each script MUST be tested with a full deploy → demo → teardown cycle in a real
  subscription before being considered done.
- Changes affecting deployment behavior MUST update the README and any teardown
  script in the same change.

## Governance

This constitution supersedes ad-hoc practices for the demo project. All changes to
deployment scripts, sample apps, and demo assets MUST comply with the principles
above. Amendments require updating this document, bumping the version per semantic
versioning, and recording the rationale. Complexity or deviations (e.g., a required
higher-cost SKU) MUST be justified in the relevant spec or plan.

**Version**: 1.0.0 | **Ratified**: 2026-06-22 | **Last Amended**: 2026-06-22
