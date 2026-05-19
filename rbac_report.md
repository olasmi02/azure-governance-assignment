# Role-Based Access Control (RBAC) Summary Report

**Student:** Olamileye Duduyemi  
**Date:** May 2026  
**Assignment:** Azure Subscriptions, Resource Groups & Governance

---

## Overview

This report outlines the Role-Based Access Control (RBAC) permissions applied across the Azure Resource Groups in this assignment. All assignments adhere to the **Principle of Least Privilege** — granting each team only the minimum permissions required to perform their duties.

---

## RBAC Assignments

### 1. Development Resource Group: `rg-governance-dev-uks`

| Scope | Principal | Role | Role Definition |
|---|---|---|---|
| `rg-governance-dev-uks` | `duduyemiolamileyeclement@gmail.com` (Dev Team) | **Contributor** | Can create, update, and delete all resources within the group, but cannot manage access (no ability to assign roles) |

**Rationale:**  
The Development team needs full operational control over the development environment — they must be able to create VMs, deploy storage accounts, modify configurations, and tear down resources as part of iterative development cycles. However, they are deliberately excluded from the `Owner` role to prevent them from altering RBAC assignments themselves, which enforces a clean separation between infrastructure engineers and access administrators.

---

### 2. Production Resource Group: `rg-governance-prod-uks`

| Scope | Principal | Role | Role Definition |
|---|---|---|---|
| `rg-governance-prod-uks` | `duduyemiolamileyeclement@gmail.com` (Ops/QA Team) | **Reader** | Can view all resources and their configurations, but cannot make any changes |

**Rationale:**  
The Operations and QA teams need visibility into the production environment for monitoring, auditing, and validating deployments — but they must never be able to modify production resources directly. The `Reader` role enforces this boundary. Any changes to production must go through a controlled deployment pipeline managed by a privileged account, preventing accidental or unauthorized modifications to live infrastructure.

---

### 3. Subscription Level

| Scope | Principal | Role |
|---|---|---|
| Subscription (`Azure subscription 1`) | Account Owner | **Owner** |

**Rationale:**  
The subscription-level `Owner` role is held exclusively by the account administrator. This ensures governance policies, RBAC assignments, and subscription-wide configurations can only be changed by an authorized administrator — not by team-level contributors.

---

## RBAC Design Principles Applied

| Principle | How It Was Applied |
|---|---|
| **Least Privilege** | Each team received only the minimum role needed for their job function |
| **Separation of Duties** | Dev team cannot modify production; Ops team cannot modify development |
| **Scope Isolation** | Roles are applied at the resource group level, not at the subscription level, to minimize blast radius |
| **No Standing Privilege** | No team has `Owner` rights on resource groups — preventing unauthorized role assignment |

---

## Azure Built-In Roles Reference

| Role | Permissions |
|---|---|
| **Owner** | Full access including role assignments |
| **Contributor** | Create & manage resources; no role assignment rights |
| **Reader** | View resources only; no modifications |
| **User Access Administrator** | Manage role assignments only; no resource management |
