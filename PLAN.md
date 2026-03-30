# Wattlink Light (LiteLink) — Product Plan

Simplified version of Wattlink for accounts that need core energy sharing functionality without the full complexity. Faster onboarding, lower support burden, discounted pricing.

---

## User Roles

**2 roles only:**

- **Manager** — full admin access (creates users, manages groups, generates billings)
- **User** — sees dashboard, addresses, billings (read-only where applicable)

**Customer/supplier distinction lives on the address level, not the user.** A single user can have both consumer and producer EANs. No need for combined/admin/accountant/sales roles.

---

## Features — What Stays

### 1. Dashboard (Simplified)

- Unified energy consumption/production chart
- Predefined date ranges only: week, month, quarter
- Activity feed
- No custom filters, no saved filter presets, no granularity switching

### 2. Groups Management

- Full group management: customers, supplier allocations, ratios
- Create sharings from group data
- Monitor active/inactive members
- Kept as-is from full version — core to how energy communities operate

### 3. Sharings

- View and manage supplier-customer sharing pairs
- Created by manager, visible to users (read-only)
- Simple fixed price per sharing

### 4. Billings — Receipts Only

- **Only `receipt` kind** — the account issues receipts to users for energy shared
- No invoices, no fee_invoices as separate documents
- Fees folded into the receipt if needed
- 2 PDF templates: VAT payer / non-VAT payer
- PDF + CSV export only (no iSDoc, Pohoda, Money S3)
- Batch receipt generation for all users in one click
- Mark as paid

### 5. Addresses

- EAN + text address + role (customer/supplier) — role lives here, not on the user
- No geocoding/map requirement
- No plant type, no capacity (kWp), no tier classification
- No visuals/images upload

### 6. Pricing — Absolute Minimum

- **One number: fixed price per kWh** on each sharing
- **One flat address fee** (optional, single number for all addresses)
- No cascade (no Sharing > User > Union > Account hierarchy)
- No peak/seasonal/volume/loyalty/tier pricing
- No MWh fee deductions, no discount variants

### 7. User Management

- Manager creates users: name, email, password
- User gets access immediately — no onboarding steps, no confirmation gates
- No delegation, no impersonation

### 8. Account Settings (Minimal)

- Account name, logo
- Billing dates (issue day, due days)
- EDC credentials (set once during initial setup by Wattlink team)

### 9. EDC Data Sync

- Automated daily sync runs as normal (readings + shares)
- No manual controls exposed — just a status indicator ("last synced: today 12:00")
- Credentials configured during initial setup

---

## Features — What Gets Removed

| Feature | Reason |
|---|---|
| Onboarding wizard (4-step) | Manager enters all data directly |
| Contracts & digital signatures | Handled offline |
| Offers / Marketplace | Sharings are pre-arranged |
| Home controller (all public pages) | No marketing site, no solutions pages, no calculator, no dictionary, no FAQ, no changelog, no contact forms |
| Custom emails | Not needed for small accounts |
| Audit logs UI | Logging still happens internally, just not exposed |
| Partner commissions | Enterprise feature |
| WattMan / gamification | Not essential |
| Unions UI | Account itself acts as the single entity |
| Lab / Scenarios / Optimization | Power-user feature, requires training |
| API keys | No third-party integrations |
| iSDoc / Pohoda / Money S3 exports | Paid add-on if requested |
| Invoice & fee_invoice billing kinds | Receipts only |
| Theme / appearance customization | Default branding only |
| Content settings / introduction content | No white-label customization |
| Dictionary / web references | Main Wattlink content only |
| Manual EDC scraping controls | Auto-sync only, no user-facing controls |
| All advanced pricing | No peak, seasonal, volume, loyalty, tiers, cascade |
| User roles (customer, supplier, combined, admin, accountant, sales) | Replaced by manager/user with role on address |

---

## Manager Panel (~7 sections)

| Section | Purpose |
|---|---|
| Users | CRUD users (name, email). Assign manager/user role. |
| Addresses | Manage EANs per user. Set customer/supplier role per address. |
| Groups | Manage energy groups, customer memberships, supplier allocations. |
| Sharings | Create/edit sharing pairs with fixed kWh price. |
| Billings | Generate receipts, batch generate, view/download PDF, mark paid. |
| Settings | Account name, logo, billing dates, EDC sync status. |
| Help | Basic guide. |

## User Panel (~3 sections)

| Section | Purpose |
|---|---|
| Dashboard | Energy chart + activity feed |
| Addresses | View their EANs (read-only) |
| Billings | View and download their receipts |

---

## Entry Point

No public-facing pages. Light accounts go straight to a **login screen**. After login:

- **Manager** -> admin panel
- **User** -> dashboard

---

## Implementation Approach

Same Wattlink codebase, gated by account plan flag. No separate app, no fork.

### Database Change

```ruby
# Add to accounts table
add_column :accounts, :plan, :string, default: "full", null: false
# Values: "full", "light"
```

### Feature Gating

- **Routes**: skip home/*, onboardings/*, contracts/*, offers/*, lab/* for light accounts
- **Navigation**: conditionally render only Light sections based on `account.light?`
- **Billing**: force `kind: :receipt`, skip invoice/fee_invoice code paths
- **Pricing**: only expose `fixed_price` + `address_fee` fields
- **User model**: only allow `manager`/`user` roles for light accounts
- **Address model**: carries the customer/supplier role
- **Dashboard**: render simplified partial without advanced filter controls

### Helper Method

```ruby
# app/models/account.rb
def light?
  plan == "light"
end

def full?
  plan == "full"
end
```

### Upgrade Path

When a light account outgrows the simplified version, flip `plan` from `"light"` to `"full"` to unlock all features. No data migration needed — the same models and tables are used.

---

## Complexity Comparison

| Metric | Full | Light | Reduction |
|---|---|---|---|
| Admin sections | 30+ | 7 | ~77% |
| User-facing sections | 8+ | 3 | ~63% |
| Onboarding steps | 4 (user-driven) | 0 (manager-driven) | 100% |
| Pricing fields | 30+ | 2 | ~93% |
| Billing kinds | 3 | 1 (receipt) | ~67% |
| Billing PDF variants | 6 | 2 | ~67% |
| Export formats | 5 | 2 (PDF + CSV) | 60% |
| User roles | 7 | 2 | ~71% |
| Support/training time | High | Minimal | ~80% |

---

## Sales Pitch

> "We set it up, you just log in and see your energy data and receipts."

- Wattlink team does a 30-minute setup call, enters all data
- Users log in and see their dashboard immediately
- Near-zero support burden — users only interact with dashboard + receipts
- Clean upgrade path to full Wattlink when the account grows
