# Azure Web Portal Instruction Path — Azure Monitor & Application Insights Demo

Step-by-step **Azure portal** (click-through) path that produces an environment
**equivalent** to the [CLI path](../cli/README.md). The portal path is a documented
alternative — never the source of truth (constitution: Infrastructure as Code).

Upstream project: [`mhuescar/azure-monitor-demo`](https://github.com/mhuescar/azure-monitor-demo)
(MIT), vendored at `../../azure-monitor-demo/`.

> Target design (matches the CLI/ARM template): Resource group → Log Analytics
> workspace → workspace-based Application Insights → Storage account → SQL Server +
> Basic database → App Service plan (B1) + Web App (.NET) → Functions app (load
> generator). See the [CLI README](../cli/README.md#what-gets-deployed) for the full
> resource table.

## Sign in & select subscription (FR-008)

1. Go to <https://portal.azure.com> and sign in.
2. Top-right → **Settings → Directories + subscriptions** (or the subscription filter)
   → confirm the **correct subscription** is active before creating anything.

## Create the resources

### 1. Resource group

1. **Create a resource** (or search **Resource groups**) → **Resource group** →
   **Create**.
2. Subscription: your subscription. Resource group: `demo-monitor-rg`.
   Region: `North Europe` (or a region offering B1 App Service + Basic SQL).
3. **Review + create** → **Create**.

### 2. Log Analytics workspace

1. **Create a resource** → search **Log Analytics workspace** → **Create**.
2. Resource group `demo-monitor-rg`; name e.g. `log-aidemo`; same region.
3. **Review + create** → **Create**.

### 3. Application Insights (workspace-based)

1. **Create a resource** → **Monitoring & Diagnostics** → **Application Insights** →
   **Create**.
2. Resource group `demo-monitor-rg`; name e.g. `appi-aidemo`; same region.
3. **Resource Mode = Workspace-based**; select the workspace from step 2.
4. **Review + create** → **Create**.

### 4. Storage account

1. **Create a resource** → **Storage account** → **Create**.
2. Resource group `demo-monitor-rg`; a globally-unique name (e.g. `staidemo<random>`);
   same region; **Redundancy = LRS**.
3. **Review + create** → **Create**.

### 5. SQL Database (Basic)

1. **Create a resource** → **SQL Database** → **Create**.
2. Resource group `demo-monitor-rg`; database name e.g. `sqldb-aidemo`.
3. **Server → Create new**: server name e.g. `sql-aidemo<random>`; **Authentication =
   SQL authentication**; admin login `demoAdmin`; set a strong password (keep it
   secret — do not store it in the repo).
4. **Compute + storage → Configure** → **Basic** tier.
5. Networking → allow **Azure services** to access the server.
6. **Review + create** → **Create**.

### 6. App Service plan (B1) + Web App

1. **Create a resource** → **Web App** → **Create**.
2. Resource group `demo-monitor-rg`; name e.g. `app-aidemo<random>`.
3. **Publish = Code**; **Runtime stack = .NET** (matches the upstream `src/web` app);
   **OS = Windows**; region same as above.
4. **App Service Plan → Create new** with **Pricing plan = Basic B1**.
5. On the **Monitoring** (or **Monitor + secure**) tab: **Enable Application Insights =
   Yes** and select `appi-aidemo` from step 3.
6. **Review + create** → **Create**.

### 7. Functions app (load generator)

1. **Create a resource** → **Function App** → **Create**.
2. Resource group `demo-monitor-rg`; name e.g. `func-load-aidemo<random>`.
3. **Runtime stack = .NET**, **isolated** worker; select the storage account from
   step 4; enable Application Insights → `appi-aidemo`.
4. **Review + create** → **Create**.

## Connect the connection string (FR-005, FR-007)

If you did not enable App Insights during Web App creation (step 6.5), wire it manually:

1. Open the **Application Insights** resource → **Overview** → **Essentials** →
   copy the **Connection string**.
2. Open the **Web App** → **Settings → Environment variables** → **+ Add**:
   name `APPLICATIONINSIGHTS_CONNECTION_STRING`, value = the copied string → **Apply**.

> The connection string identifies the destination resource; it is not a secret you
> should commit to source, but it is safe to paste into app settings in the portal.

## Deploy the app code

The portal does not build the upstream code for you. Deploy `azure-monitor-demo/src/web`
to the Web App using your preferred method (VS Code Azure extension, **Deployment
Center**, or zip deploy). For a fully scripted alternative, use the
[CLI path](../cli/README.md).

## Verify telemetry (SC-003)

1. Browse the Web App and hit `/api/health`, `/api/simulate-error`, `/api/load-test`,
   `/api/memory-test`.
2. **Application Insights → Live Metrics** → activity should appear within ~5 minutes.
3. If nothing appears: confirm the `APPLICATIONINSIGHTS_CONNECTION_STRING` app setting
   on the Web App, then re-generate traffic.

## Edge cases

- **Wrong subscription** → switch the active subscription before creating resources.
- **Resource-name collision** → the portal shows a validation error (especially for
  globally-unique storage/SQL/web names); choose a different name.
- **Region without a required SKU** → the option is disabled or flagged at create
  time; choose a region offering B1 App Service + Basic SQL.

## Teardown (FR-006, SC-005)

1. **Resource groups** → `demo-monitor-rg` → **Delete resource group**.
2. Type the resource group name to confirm → **Delete**.

## Demo walkthrough

See [demo walkthrough](../demo-walkthrough.md) for the suggested presentation flow.
