---
title: Cost Notes
nav_order: 5
---

# Approximate Cost Notes

> **These figures are approximate and illustrative only.** Azure pricing varies by
> region, currency, subscription type, and changes over time. Always confirm against
> the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) and
> your own subscription. No figure here is a billing guarantee (constitution: Honesty &
> Source Fidelity; Cost Control).

The demo provisions low-tier resources to keep cost small while still showing real
telemetry. Rough order-of-magnitude daily estimates (pay-as-you-go, a low-cost region):

| Resource | SKU | Approx. cost driver |
|----------|-----|---------------------|
| App Service plan | B1 (Windows) | Largest single cost (~$13/mo class) |
| Azure SQL Database | Basic (5 DTU) | ~$5/mo class |
| Application Insights | workspace-based | Pay per GB ingested; tiny at demo volume |
| Log Analytics workspace | PerGB2018, 30-day | Pay per GB ingested; tiny at demo volume |
| Storage account | Standard_LRS | Negligible at demo volume |
| Functions app | Consumption / plan | Negligible at demo volume |

**Approximate total: well under ~$1/day** if left running, dominated by the App
Service plan and SQL database. The exact number depends on region and telemetry
ingestion volume.

## Keep cost near zero

- **Delete the resource group as soon as the demo ends** (the single biggest lever):

  ```powershell
  az group delete --name demo-monitor-rg --yes --no-wait
  ```

- Deploy only when presenting; do not leave the environment running overnight.
- Application Insights / Log Analytics ingestion is volume-based — the bundled load
  generator runs every 5 minutes, so tearing down promptly also caps ingestion cost.
