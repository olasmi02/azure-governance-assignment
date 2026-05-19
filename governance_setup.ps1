# =============================================================================
# Azure Cloud Governance Setup Script
# Assignment: Azure Subscriptions, Resource Groups & Governance
# Student:    Olamileye Duduyemi | May 2026
# =============================================================================

$SUBSCRIPTION_ID = "9335a9cd-ae74-439b-94b3-d965ca478c53"
$LOCATION        = "uksouth"
$PROJECT         = "azure-governance-assignment"
$CREATED_BY      = "duduyemiolamileyeclement@gmail.com"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Azure Cloud Governance Setup" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ── Verify Azure login ────────────────────────────────────────────────────────
Write-Host "[1/6] Checking Azure login..." -ForegroundColor Yellow
$ACCOUNT = az account show --output json 2>$null | ConvertFrom-Json
if (-not $ACCOUNT) {
    Write-Host "  Not logged in. Running az login..." -ForegroundColor Red
    az login
    $ACCOUNT = az account show --output json | ConvertFrom-Json
}
Write-Host "  Logged in as: $($ACCOUNT.user.name)" -ForegroundColor Green
Write-Host "  Subscription: $($ACCOUNT.name) ($($ACCOUNT.id))" -ForegroundColor Green
Write-Host ""

# ── Set active subscription ───────────────────────────────────────────────────
az account set --subscription $SUBSCRIPTION_ID

# ── Create Resource Groups ────────────────────────────────────────────────────
Write-Host "[2/6] Creating Resource Groups..." -ForegroundColor Yellow

Write-Host "  Creating rg-governance-dev-uks..." -ForegroundColor White
az group create `
    --name "rg-governance-dev-uks" `
    --location $LOCATION `
    --tags environment=dev owner=team-dev project=$PROJECT `
            costCenter=cc-dev-001 region=uk-south createdBy=$CREATED_BY `
    --output none
Write-Host "  [OK] rg-governance-dev-uks" -ForegroundColor Green

Write-Host "  Creating rg-governance-prod-uks..." -ForegroundColor White
az group create `
    --name "rg-governance-prod-uks" `
    --location $LOCATION `
    --tags environment=prod owner=team-ops project=$PROJECT `
            costCenter=cc-prod-001 region=uk-south createdBy=$CREATED_BY `
    --output none
Write-Host "  [OK] rg-governance-prod-uks" -ForegroundColor Green

Write-Host "  Creating rg-governance-test-uks (temporary)..." -ForegroundColor White
az group create `
    --name "rg-governance-test-uks" `
    --location $LOCATION `
    --tags environment=test owner=team-dev project=$PROJECT `
    --output none
Write-Host "  [OK] rg-governance-test-uks" -ForegroundColor Green
Write-Host ""

# ── Deploy Log Analytics Workspaces ───────────────────────────────────────────
Write-Host "[3/7] Deploying Log Analytics Workspaces..." -ForegroundColor Yellow

Write-Host "  Creating log-governance-dev-uks in Dev RG..." -ForegroundColor White
az monitor log-analytics workspace create `
    --workspace-name "log-governance-dev-uks" `
    --resource-group "rg-governance-dev-uks" `
    --location $LOCATION `
    --tags environment=dev owner=team-dev project=$PROJECT costCenter=cc-dev-001 `
    --output none
Write-Host "  [OK] log-governance-dev-uks" -ForegroundColor Green

Write-Host "  Creating log-governance-prod-uks in Prod RG..." -ForegroundColor White
az monitor log-analytics workspace create `
    --workspace-name "log-governance-prod-uks" `
    --resource-group "rg-governance-prod-uks" `
    --location $LOCATION `
    --tags environment=prod owner=team-ops project=$PROJECT costCenter=cc-prod-001 `
    --output none
Write-Host "  [OK] log-governance-prod-uks" -ForegroundColor Green
Write-Host ""

# ── Deploy Storage Accounts ───────────────────────────────────────────────────
Write-Host "[4/7] Deploying Storage Accounts..." -ForegroundColor Yellow

Write-Host "  Creating stgovdev9482 in Dev RG..." -ForegroundColor White
az storage account create `
    --name "stgovdev9482" `
    --resource-group "rg-governance-dev-uks" `
    --location $LOCATION `
    --sku Standard_LRS `
    --kind StorageV2 `
    --tags environment=dev owner=team-dev project=$PROJECT costCenter=cc-dev-001 `
    --output none
Write-Host "  [OK] stgovdev9482" -ForegroundColor Green

Write-Host "  Creating stgovprod9482 in Prod RG..." -ForegroundColor White
az storage account create `
    --name "stgovprod9482" `
    --resource-group "rg-governance-prod-uks" `
    --location $LOCATION `
    --sku Standard_LRS `
    --kind StorageV2 `
    --tags environment=prod owner=team-ops project=$PROJECT costCenter=cc-prod-001 `
    --output none
Write-Host "  [OK] stgovprod9482" -ForegroundColor Green
Write-Host ""

# ── Assign RBAC Roles ─────────────────────────────────────────────────────────
Write-Host "[5/7] Assigning RBAC Roles..." -ForegroundColor Yellow

$DEV_SCOPE  = "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-governance-dev-uks"
$PROD_SCOPE = "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-governance-prod-uks"

Write-Host "  Assigning Contributor on Dev RG..." -ForegroundColor White
az role assignment create `
    --role "Contributor" `
    --assignee $CREATED_BY `
    --scope $DEV_SCOPE `
    --output none 2>$null
Write-Host "  [OK] Contributor on rg-governance-dev-uks" -ForegroundColor Green

Write-Host "  Assigning Reader on Prod RG..." -ForegroundColor White
az role assignment create `
    --role "Reader" `
    --assignee $CREATED_BY `
    --scope $PROD_SCOPE `
    --output none 2>$null
Write-Host "  [OK] Reader on rg-governance-prod-uks" -ForegroundColor Green
Write-Host ""

# ── Lifecycle Test: Delete Test RG ────────────────────────────────────────────
Write-Host "[6/7] Lifecycle Test – Deleting Test Resource Group..." -ForegroundColor Yellow
az group delete --name "rg-governance-test-uks" --yes --no-wait
Write-Host "  [OK] rg-governance-test-uks deletion initiated (async)" -ForegroundColor Green
Write-Host ""

# ── Verify Final State ────────────────────────────────────────────────────────
Write-Host "[7/7] Final State – Resource Groups in Subscription:" -ForegroundColor Yellow
az group list --query "[?tags.project=='$PROJECT'].{Name:name, Location:location, State:properties.provisioningState}" --output table
Write-Host ""

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Take screenshots in the Azure Portal (see README)" -ForegroundColor White
Write-Host "  2. Push all files to your GitHub repo" -ForegroundColor White
Write-Host ""
