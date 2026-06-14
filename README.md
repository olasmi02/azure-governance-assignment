# Azure Cloud Governance – Resource Organization Strategy

**Student:** Olamileye Duduyemi  
**Date:** May 2026  
**Assignment:** Azure Subscriptions, Resource Groups & Governance  
**Subscription:** Azure subscription 1 (`9335a9cd-ae74-439b-94b3-d965ca478c53`)

---

## 1. Naming Convention

A consistent naming convention is critical for scalability, clarity, and automation. The convention used in this project follows the **Microsoft Cloud Adoption Framework (CAF)** pattern:

```
{resource-type}-{workload}-{environment}-{region-short}
```

### Component Definitions

| Component | Description | Values Used |
|---|---|---|
| `resource-type` | Abbreviated resource type prefix | `rg` (Resource Group), `vm` (Virtual Machine), `st` (Storage), `sql` (Database) |
| `workload` | Application or workload identifier | `governance` |
| `environment` | Deployment environment | `dev`, `prod`, `test` |
| `region-short` | Abbreviated Azure region code | `uks` (UK South) |

### Applied Examples

| Resource | Name | Rationale |
|---|---|---|
| Dev Resource Group | `rg-governance-dev-uks` | Hosts all development-tier resources |
| Prod Resource Group | `rg-governance-prod-uks` | Hosts all production-tier resources |
| Test Resource Group | `rg-governance-test-uks` | Temporary group for lifecycle testing |
| Dev Virtual Machine | `vm-governance-dev-uks` | Linux VM for development workloads |
| Dev Log Analytics | `log-governance-dev-uks` | Log Analytics workspace for Dev |
| Prod Log Analytics | `log-governance-prod-uks` | Log Analytics workspace for Prod |
| Dev Storage Account | `stgovdev9482` | Dev storage (no hyphens, all lowercase, random suffix) |
| Prod Storage Account | `stgovprod9482` | Prod storage (no hyphens, all lowercase, random suffix) |
| Prod SQL Database | `sql-governance-prod-uks` | Azure SQL Database in production |

> **Note:** Storage Account names must be 3–24 characters, lowercase, and alphanumeric only — hence the deviation from the standard pattern.

---

## 2. Resource Organization Strategy

### Azure Resource Hierarchy

Azure provides a hierarchical structure to organize resources, manage access, and apply governance policies at scale. The hierarchy consists of five main levels:

1. **Tenant (Microsoft Entra ID)**: The top-level administrative and identity boundary in the Microsoft Cloud. It represents a single organization. A tenant hosts user accounts, groups, and application registrations, serving as the central identity and access management (IAM) boundary.
2. **Management Groups**: Logical containers used to manage access, policy, and compliance across multiple subscriptions. All subscriptions within a management group automatically inherit the conditions (RBAC, policies) applied to it.
3. **Subscriptions**: Containers that group resource groups and resources together. Each subscription is linked to a single tenant, has its own billing terms, and acts as a quota and scale limit boundary.
4. **Resource Groups**: Logical folders where Azure resources are deployed and managed. They serve as a lifecycle boundary, allowing related resources for a specific workload or environment to be created, updated, and deleted as a single unit.
5. **Resources**: The individual service instances provisioned in Azure (such as Log Analytics Workspaces, Storage Accounts, and Virtual Machines).

---

### Subscription Structure

All resources are deployed under a single subscription:

```
Azure subscription 1
├── rg-governance-dev-uks     (Development environment)
├── rg-governance-prod-uks    (Production environment)
└── rg-governance-test-uks    (Temporary – lifecycle management test)
```


### Rationale

- **Environment Isolation:** Separating Dev and Prod into distinct resource groups prevents accidental changes to production infrastructure.
- **Collective Lifecycle Management:** All resources for a given environment are co-located, enabling a single delete operation to tear down an entire environment.
- **Cost Allocation:** Resource group-level tags allow Azure Cost Management to aggregate spending per environment, team, and project.
- **Access Boundary:** RBAC is applied at the resource group level, giving fine-grained control without needing per-resource role assignments.

---

## 3. Tagging Strategy

Tags are applied to every resource group and propagated to individual resources. The following key-value schema is used:

| Tag Key | Description | Example Values |
|---|---|---|
| `environment` | Deployment tier | `dev`, `prod`, `test` |
| `owner` | Responsible team | `team-dev`, `team-ops` |
| `project` | Project identifier | `azure-governance-assignment` |
| `costCenter` | Billing code | `cc-dev-001`, `cc-prod-001` |
| `region` | Human-readable region | `uk-south` |
| `createdBy` | Provisioning identity | `duduyemiolamileyeclement@gmail.com` |

### Applied Tag Sets

**Development Resource Group (`rg-governance-dev-uks`)**
```
environment  = dev
owner        = team-dev
project      = azure-governance-assignment
costCenter   = cc-dev-001
region       = uk-south
createdBy    = duduyemiolamileyeclement@gmail.com
```

**Production Resource Group (`rg-governance-prod-uks`)**
```
environment  = prod
owner        = team-ops
project      = azure-governance-assignment
costCenter   = cc-prod-001
region       = uk-south
createdBy    = duduyemiolamileyeclement@gmail.com
```

---

## 4. Infrastructure as Code – CLI Commands

The following Azure CLI commands were used to provision the infrastructure automatically. See `governance_setup.ps1` for the full automation script.

### Create Resource Groups
```bash
# Development
az group create \
  --name rg-governance-dev-uks \
  --location uksouth \
  --tags environment=dev owner=team-dev project=azure-governance-assignment \
          costCenter=cc-dev-001 region=uk-south \
          createdBy=duduyemiolamileyeclement@gmail.com

# Production
az group create \
  --name rg-governance-prod-uks \
  --location uksouth \
  --tags environment=prod owner=team-ops project=azure-governance-assignment \
          costCenter=cc-prod-001 region=uk-south \
          createdBy=duduyemiolamileyeclement@gmail.com

# Test (temporary)
az group create \
  --name rg-governance-test-uks \
  --location uksouth \
  --tags environment=test owner=team-dev project=azure-governance-assignment
```

### Deploy Resources into Groups
```bash
# Log Analytics Workspace in Dev
az monitor log-analytics workspace create \
  --resource-group rg-governance-dev-uks \
  --workspace-name log-governance-dev-uks \
  --location uksouth \
  --tags environment=dev owner=team-dev project=azure-governance-assignment costCenter=cc-dev-001

# Log Analytics Workspace in Prod
az monitor log-analytics workspace create \
  --resource-group rg-governance-prod-uks \
  --workspace-name log-governance-prod-uks \
  --location uksouth \
  --tags environment=prod owner=team-ops project=azure-governance-assignment costCenter=cc-prod-001

# Storage Account in Dev
az storage account create \
  --name stgovdev9482 \
  --resource-group rg-governance-dev-uks \
  --location uksouth \
  --sku Standard_LRS \
  --tags environment=dev owner=team-dev project=azure-governance-assignment costCenter=cc-dev-001

# Storage Account in Prod
az storage account create \
  --name stgovprod9482 \
  --resource-group rg-governance-prod-uks \
  --location uksouth \
  --sku Standard_LRS \
  --tags environment=prod owner=team-ops project=azure-governance-assignment costCenter=cc-prod-001
```

### Assign RBAC Roles
```bash
# Grant Contributor on Dev RG to the dev team
az role assignment create \
  --role "Contributor" \
  --assignee duduyemiolamileyeclement@gmail.com \
  --scope /subscriptions/9335a9cd-ae74-439b-94b3-d965ca478c53/resourceGroups/rg-governance-dev-uks

# Grant Reader on Prod RG to the QA team
az role assignment create \
  --role "Reader" \
  --assignee duduyemiolamileyeclement@gmail.com \
  --scope /subscriptions/9335a9cd-ae74-439b-94b3-d965ca478c53/resourceGroups/rg-governance-prod-uks
```

### Delete the Test Resource Group (Lifecycle Demo)
```bash
az group delete --name rg-governance-test-uks --yes --no-wait
```

---

## 5. Project File Structure

```
Assignment 3/
├── README.md                 # This document (naming conventions & strategy)
├── rbac_report.md            # RBAC roles assigned and rationale
├── governance_setup.ps1      # PowerShell/Azure CLI automation script
└── screenshots/              # Azure Portal evidence screenshots
    ├── 01_resource_groups_overview.png
    ├── 02_rg_dev_overview.png
    ├── 03_rg_dev_tags.png
    ├── 04_rg_prod_overview.png
    ├── 05_rg_prod_tags.png
    └── 06_rbac_assignments.png
```
