# LiteLink — Development Plan

Phased implementation plan. Each phase is a deployable increment. Heavy reuse of wattlink patterns, models, services, and design system.

Reference: `PLAN.md` for product spec, `CLAUDE.md` for dev practices.

Wattlink source: `/Users/patrikjira/Work/wattlink`

---

## Phase 1: Foundation

Everything needed before any feature work. Copy and adapt core infrastructure from wattlink.

### 1.1 Gemfile Setup

Adapt from wattlink's Gemfile. Add only what LiteLink needs:

```ruby
gem "rails", "~> 8.0"
gem "pg"
gem "puma"
gem "bcrypt"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "bootstrap"
gem "sassc-rails"
gem "pundit"
gem "simple_command"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "redis"
gem "kaminari"
gem "bootstrap5-kaminari-views"
gem "wicked_pdf"
gem "wkhtmltopdf-binary"
gem "rqrcode"
gem "sentry-ruby"
gem "sentry-rails"
gem "image_processing"
gem "aws-sdk-s3"
gem "premailer-rails"

group :development, :test do
  gem "debug"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "letter_opener_web"
end

group :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "capybara"
  gem "cuprite"
end
```

Skip from wattlink: `geocoder`, `caxlsx`, `roo`, `acts_as_list`, `ruby_llm`, `glpk`, `lexxy`, `lupina` (lab/optimization gems not needed).

### 1.2 Design System

Copy the entire DS from wattlink — this is our UI foundation and we use it more thoroughly than wattlink does.

**Copy these files:**
- `app/assets/stylesheets/ds/` — entire directory (all 24 SCSS component files)
- `app/assets/stylesheets/ds/configuration.scss` — CSS variables, colors, typography tokens
- `app/assets/stylesheets/ds/app.scss` — main app shell layout

**Create `app/assets/stylesheets/application.bootstrap.scss`:**
Import Bootstrap first, then DS configuration, then DS components. Import order matters:

1. Bootstrap (base framework)
2. `ds/configuration` (tokens and variables)
3. All DS components: button, badge, card, table, form, alert, modal, listing, tabs, pagination, icon, nav, box, stat_card, filter_panel, status_button, tom_select, calendar
4. App-specific overrides (sessions, dashboard, billing — add as needed per phase)

**Copy external library setup from wattlink's `_head.html.erb`:**
- Font Awesome 6 (CDN)
- Google Fonts — Manrope (weights 200-800)
- Flatpickr (date pickers)
- Tom Select (enhanced selects)

**Stimulus controllers to copy from wattlink:**
- `copy_controller.js` — copy to clipboard
- `autoresize_controller.js` — textarea auto-resize
- `dismissable_controller.js` — alert/flash dismissal
- `password_toggle_controller.js` — show/hide password
- `field_info_controller.js` — field tooltips
- `confirm_delete_controller.js` — delete confirmation modals

Add more controllers as needed in later phases (chart, filter, etc.).

### 1.3 Account & Current Model

**Adapt `Account` from wattlink:**

```
accounts table:
  - name (string)
  - subdomain (string, unique)
  - settings (jsonb, default: {})
  - plan (string, default: "light") ← NEW, not in wattlink
  - timestamps
```

Settings store (simplified from wattlink — drop onboarding/theme/content settings):
- `issue_day_in_month`
- `supply_day_in_month`
- `due_days`
- `billing_copy_email`

Attachments: `logo` only (drop email_logo, subdomain_picture, favicon).

Methods: `light?`, `full?` (new), plus wattlink's `wattlink?` and `on_subdomain?` patterns.

**Copy `Current` model from wattlink** (simplified):

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :account, :user
end
```

Drop: `subdomain_account`, `introduction_content`, `impersonated_by_superadmin`.

### 1.4 User Model & Authentication

**Adapt `User` from wattlink:**

```
users table:
  - account_id (references)
  - name (string)
  - email (string, unique)
  - phone (string)
  - password_digest (string)
  - role (string, default: "user") ← "manager" or "user"
  - confirmed (boolean, default: true) ← always true, no confirmation flow
  - timestamps
```

Key patterns to replicate:
- `has_secure_password` (bcrypt, same as wattlink)
- Email normalization (downcase + strip, same pattern)
- Role enum: `{ manager: "manager", user: "user" }`
- `manager?`, `user?` helper methods
- Superadmin check via email whitelist (same pattern as wattlink)

**Skip from wattlink user:** secondary_email, onboarding fields, profile association, offer association, settings JSONB (not needed — no notification preferences), user_tokens (no confirmation flow), contracts, feeds.

**Adapt `SessionsController` from wattlink:**
- Email + password login
- `session[:user_id]` storage
- Redirect to dashboard after login
- Flash messages for wrong password / user not found
- No SSO cookie logic (LiteLink is standalone, not part of wattlink SSO network)

**Copy from wattlink:**
- `sessions/new.html.erb` — login page view (uses DS `.Sessions` layout)
- Session layout (`_session.html.erb`)
- Password reset flow: `UserToken` model, `PasswordResetsController`, mailer (same pattern)

### 1.5 ApplicationController

**Adapt from wattlink's ApplicationController:**

```ruby
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  protect_from_forgery with: :exception

  before_action :set_currents
  before_action :login_required

  helper_method :current_user, :logged_in?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def set_currents
    Current.user = User.find_by(id: session[:user_id])
    Current.account = Current.user&.account
  end

  def logged_in?
    session[:user_id].present?
  end

  def current_user
    Current.user
  end

  def login_required
    redirect_to new_session_path unless logged_in?
  end

  def user_not_authorized
    flash[:alert] = t("common.not_authorized")
    redirect_back fallback_location: root_path
  end

  def record_not_found
    redirect_to root_path, alert: t("common.not_found")
  end
end
```

Drop from wattlink: SubdomainScoped concern, SsoAuthenticatable concern, Sentry user tracking, impersonation logic, active_storage_url_options.

### 1.6 AppController (Authenticated Base)

**Adapt from wattlink's AppController:**

```ruby
class AppController < ApplicationController
  layout "app"
end
```

Drop audit logging for now (not exposed in Light). Can add internal logging later if needed.

### 1.7 Layouts

**Copy and adapt from wattlink:**

- `layouts/application.html.erb` — base layout (simplified, no theme rendering)
- `layouts/app.html.erb` — authenticated app layout with `.App` shell, header, nav, content area
- `layouts/_head.html.erb` — fonts, icons, stylesheets, JS imports
- `layouts/_flash.html.erb` — flash message rendering using DS `.Alert` component
- `layouts/_session.html.erb` — login page layout (two-column with billboard)
- `application/_top.html.erb` — header navigation (simplified for LiteLink's fewer sections)

**Navigation items for manager:**
Dashboard | Users | Addresses | Groups | Sharings | Billings | Settings

**Navigation items for user:**
Dashboard | Addresses | Billings

### 1.8 ApplicationHelper

**Copy key helpers from wattlink's `application_helper.rb`:**

- `icon(name, text, css_class, font_style)` — FontAwesome renderer
- `copyable_field(value)` — copy to clipboard
- `flash_to_alert(name)` — flash type to DS Alert class mapping
- `error_message_for(object, attribute)` — form validation display
- `error_class_for(object, attribute)` — is-invalid class
- `disable_with` — submit button loading state
- `boolean_to_yes_no(value)` — localized boolean
- `app_logo_tag(css_class)` — account logo rendering
- `active_if(controller)` — nav active state

Drop from wattlink: `render_ean_with_address`, `sharing_status_for_pair`, `og_*` meta helpers, billboard helpers, changelog helpers, theme helpers.

### 1.9 Pundit Policies

**Copy `ApplicationPolicy` from wattlink** (default-deny base policy).

Create initial policies:
- `UserPolicy` — manager can CRUD, user can view self
- `AccountPolicy` — manager only

### 1.10 I18n Setup

- Set default locale to `:cs` in `config/application.rb`
- Set timezone to `"Prague"`
- Create `config/locales/cs.yml` with base translations
- Use Czech URL paths in routes (same convention as wattlink: `/prihlaseni`, `/sprava`, `/nastaveni`)

### 1.11 Test Setup

**Copy and adapt from wattlink:**

- `test/test_helper.rb` — FactoryBot include, parallel execution, fresh `@account` per test
- `test/factories.rb` — account, user (with manager trait), address factories
- `test/application_system_test_case.rb` — Capybara + Cuprite base class with `login_as` helper
- Test environment config: inline jobs, test mailer, CSRF disabled

### 1.12 Routes (Phase 1)

```ruby
root "sessions#new"

resource :session, path: "prihlaseni"
resources :password_resets, path: "obnova-hesla", only: [:new, :create, :edit, :update]

resources :dashboards, path: "prehled", only: [:index]
```

### Phase 1 Tests

- User model: validations, role methods, authentication
- Account model: settings, plan methods
- SessionsController: login success, wrong password, redirect
- System test: login flow end-to-end

---

## Phase 2: User & Address Management

Manager can create users and assign addresses with EANs.

### 2.1 Manager Namespace

Create `Manager::` namespace (equivalent to wattlink's `Admin::` but named for LiteLink's role).

```ruby
namespace :manager, path: "sprava" do
  resources :users, path: "uzivatele"
  resources :addresses, path: "adresy"
end
```

**Route constraint** (same pattern as wattlink's `AdminConstraint`):

```ruby
class ManagerConstraint
  def matches?(request)
    user = User.find_by(id: request.session[:user_id])
    user&.manager?
  end
end
```

### 2.2 Manager::UsersController

CRUD for users within the account. Adapt from wattlink's `Admin::UsersController`.

**Views using DS components:**
- Index: `.Listing` component with `.Listing__item` per user, `.Badge` for role, `.Listing__pagination` with kaminari
- New/Edit: `.Form` component with `.Form__group`, `.Form__label`, `.Form__input`, validation feedback
- Show: `.Card` with user details, `.Box` with address list

### 2.3 Address Model

**Adapt from wattlink:**

```
addresses table:
  - user_id (references)
  - account_id (references)
  - ean (string)
  - role (string) ← "customer" or "supplier"
  - street (string)
  - city (string)
  - zip (string)
  - label (string)
  - timestamps
```

Skip from wattlink: latitude/longitude, plant_type, plant_capacity, tier, edc flag, tag, orp fields, valid_from/valid_to, images.

Validations: EAN presence and format, role inclusion, uniqueness of EAN within account.

### 2.4 Manager::AddressesController

CRUD for addresses. Each address belongs to a user and has a role (customer/supplier).

**Views:**
- Index: `.Table` component — columns: EAN, User, Role (`.Badge--customer` / `.Badge--supplier`), Address, Actions
- New/Edit: `.Form` with user select (Tom Select), EAN input, role radio buttons, address fields

### 2.5 Pundit Policies

- `Manager::UserPolicy` — manager of same account can CRUD
- `Manager::AddressPolicy` — manager of same account can CRUD

### Phase 2 Tests

- Address model: validations, role enum, EAN format
- Manager::UsersController: CRUD operations, authorization (user role blocked)
- Manager::AddressesController: CRUD operations, user association
- System test: manager creates user, adds address with EAN

---

## Phase 3: Groups & Sharings

Core energy sharing domain. Adapted from wattlink's groups/sharings system.

### 3.1 Group Model

**Adapt from wattlink:**

```
groups table:
  - account_id (references)
  - name (string)
  - identifier (string)
  - timestamps
```

Associations:
- `has_many :group_customers`
- `has_many :group_supplier_allocations, through: :group_customers`

Methods to copy from wattlink: `unique_sharing_pairs`, `customers_with_suppliers`, `suppliers_with_customers`.

### 3.2 GroupCustomer Model

**Copy from wattlink:**

```
group_customers table:
  - group_id (references)
  - ean (string)
  - valid_from (date)
  - valid_to (date)
  - timestamps
```

Scopes: `active` (current date in range).

### 3.3 GroupSupplierAllocation Model

**Copy from wattlink:**

```
group_supplier_allocations table:
  - group_customer_id (references)
  - ean (string)
  - allocation_ratio (decimal)
  - allocation_order (integer)
  - timestamps
```

### 3.4 Sharing Model

**Adapt from wattlink:**

```
sharings table:
  - account_id (references)
  - from_address_id (references) ← supplier
  - to_address_id (references) ← customer
  - from_ean (string)
  - to_ean (string)
  - status (string, default: "active")
  - fixed_price (decimal) ← simple price per kWh, NEW field
  - timestamps
```

Status enum: `{ pending: "pending", active: "active", inactive: "inactive" }`

Key simplification vs wattlink: `fixed_price` lives directly on the sharing. No SharingPrice history table, no Pricing model, no PricingAssignment. One price per sharing, editable by manager.

### 3.5 Manager::GroupsController

**Adapt from wattlink's Admin::GroupsController:**

- Index: list groups with member counts
- Show: group details with customer list and supplier allocations
- New/Edit: group form
- Nested management: add/remove customers, manage supplier allocations per customer
- Action: create sharings from group pairs (same as wattlink's `create_sharings` action)

**Views using DS:**
- Index: `.Listing` with `.Card` per group showing stats
- Show: `.Table` for customers, nested `.Table` for supplier allocations per customer
- Allocation editing: `.Form` inline with ratio input

### 3.6 Manager::SharingsController

**Adapt from wattlink's Admin::SharingsController (simplified):**

- Index: list all sharings with from/to EAN, price, status
- New: select supplier address + customer address + price
- Edit: change price or status
- Batch create from group (link from group show page)

**Views:**
- Index: `.Table` — From EAN, To EAN, Price (Kc/kWh), Status (`.Badge`), Actions
- Form: `.Form` with address selects (Tom Select), price input, status select

### 3.7 SharingCreationService

**Adapt from wattlink's sharing creation logic:**

Service to batch-create sharings from a group's customer-supplier pairs. Input: group. Output: created sharings array.

```ruby
class CreateSharingsFromGroup
  prepend SimpleCommand

  def initialize(group, default_price: nil)
    @group = group
    @default_price = default_price
  end

  def call
    @group.unique_sharing_pairs.map do |pair|
      from_address = Address.find_by(ean: pair[:supplier_ean], account: @group.account)
      to_address = Address.find_by(ean: pair[:customer_ean], account: @group.account)
      next unless from_address && to_address

      Sharing.find_or_create_by!(
        from_address: from_address,
        to_address: to_address,
        account: @group.account
      ) do |sharing|
        sharing.from_ean = pair[:supplier_ean]
        sharing.to_ean = pair[:customer_ean]
        sharing.fixed_price = @default_price
        sharing.status = :active
      end
    end.compact
  end
end
```

### Phase 3 Tests

- Group model: associations, unique_sharing_pairs method
- GroupCustomer: active scope, date range validation
- GroupSupplierAllocation: allocation_ratio validation (0-1)
- Sharing model: validations, status enum, fixed_price
- CreateSharingsFromGroup service: creates from group pairs, handles duplicates
- Manager::GroupsController: CRUD, customer/allocation management
- Manager::SharingsController: CRUD, price editing
- System test: manager creates group, adds members, generates sharings

---

## Phase 4: EDC Data & Dashboard

Import energy data and display it on the dashboard.

### 4.1 EDC Models

**Copy from wattlink:**

```
edc_shares table:
  - from_ean (string)
  - to_ean (string)
  - value (decimal) ← kWh
  - shared_at (datetime)
  - unique index on [from_ean, to_ean, shared_at]

edc_readings table:
  - ean (string)
  - original (decimal)
  - final (decimal)
  - shared_at (datetime)
  - unique index on [ean, shared_at]
```

Models are minimal data containers — copy as-is from wattlink.

### 4.2 EDC Credential Storage

**Adapt from wattlink:**

```
credentials table:
  - account_id (references)
  - username (string, encrypted)
  - password (string, encrypted)
  - timestamps
```

Use ActiveRecord encryption (same as wattlink). Credentials entered once during setup, not exposed in UI.

### 4.3 EDC Scraping Jobs

**Copy from wattlink** (these are infrastructure, not features):

- `Scrape::DailyReadingJob` — daily meter readings
- `Scrape::DailyShareJob` — daily energy share data
- `AfternoonJob` — orchestrator that triggers both (runs at 12 PM via sidekiq-scheduler)

These use Capybara + Cuprite for headless browser automation against the EDC portal. Copy the scraping logic as-is — it doesn't change for LiteLink.

Add `capybara` and `cuprite` to production Gemfile (not just test group).

### 4.4 Dashboard

**Adapt from wattlink's DashboardsController (simplified):**

One view for all users. Manager sees account-wide data, user sees their own.

**DashboardsController:**
```ruby
class DashboardsController < AppController
  def index
    @addresses = policy_scope(Address)
    @date_range = params[:range] || "month"
    @chart_data = DashboardChartService.call(@addresses, @date_range)
  end
end
```

**DashboardChartService** (new, simplified from wattlink's UnifiedChartDataService):

Queries `Edc::Share` and `Edc::Reading` for the user's EANs within the selected date range. Returns data formatted for Chart.js.

Predefined ranges only:
- `week` — last 7 days (daily aggregation)
- `month` — last 30 days (daily aggregation)
- `quarter` — last 90 days (weekly aggregation)

**Views using DS:**
- `.StatCardGrid` at top: total consumption, total production, total shared (kWh)
- Chart.js line/bar chart (copy wattlink's chart rendering pattern)
- `.Card` for chart container
- Radio buttons for date range (`.Tabs` component)
- No filter panel, no saved filters, no granularity switching

**Stimulus controllers to copy from wattlink:**
- Chart controller (adapt from wattlink's unified chart controller)
- Date range selector (simple, new)

**EDC sync status indicator:**
- Small `.Badge` in settings showing last sync time
- Query: `Edc::Share.where(from_ean: account_eans).maximum(:shared_at)`

### Phase 4 Tests

- Edc::Share model: uniqueness validation, scopes by EAN/date
- Edc::Reading model: uniqueness validation
- DashboardChartService: returns correct structure, handles empty data, respects date ranges
- DashboardsController: renders for manager, scopes data for user
- System test: user sees dashboard with chart after EDC data exists

---

## Phase 5: Billing

Receipt generation, PDF, batch operations, payment tracking.

### 5.1 Billing Model

**Adapt from wattlink (simplified):**

```
billings table:
  - account_id (references)
  - user_id (references)
  - kind (string, default: "receipt") ← only receipts
  - status (string, default: "active")
  - period (string, default: "monthly")
  - start_at (date)
  - end_at (date)
  - issue_date (date)
  - supply_date (date)
  - due_date (date)
  - variable_symbol (string)
  - timestamps
```

Attachment: `has_one_attached :document` (PDF).

Status enum: `{ active: "active", paid: "paid" }`

Methods from wattlink to adapt:
- `total_to_pay`, `total_to_receive` (sum billing items by transaction_type)
- `net_amount`, `subtotal`
- `vat_amount` (simple: subtotal * 0.21 if VAT payer)
- `total_price_with_vat`
- `due_date` auto-calculation from account settings

### 5.2 BillingItem Model

**Adapt from wattlink (simplified):**

```
billing_items table:
  - billing_id (references)
  - sharing_id (references)
  - kind (string, default: "sharings") ← only sharings kind
  - transaction_type (string) ← "pay" or "receive"
  - amount (decimal) ← kWh
  - price (decimal) ← total price (amount * unit_price)
  - name (string) ← counterparty description
  - timestamps
```

### 5.3 BillingItemsCreator Service

**Simplified from wattlink's 443-line service:**

```ruby
class BillingItemsCreator
  prepend SimpleCommand

  def initialize(billing)
    @billing = billing
    @user = billing.user
    @account = billing.account
  end

  def call
    active_sharings.each do |sharing|
      total_kwh = edc_shares_for(sharing).sum(:value)
      next if total_kwh.zero?

      is_supplier = sharing.from_address.user == @user
      transaction = is_supplier ? :receive : :pay

      @billing.billing_items.create!(
        sharing: sharing,
        kind: :sharings,
        transaction_type: transaction,
        amount: total_kwh,
        price: total_kwh * sharing.fixed_price,
        name: counterparty_name(sharing, is_supplier)
      )
    end
  end

  private

  def active_sharings
    user_eans = @user.addresses.pluck(:ean)
    Sharing.active.where(account: @account)
      .where("from_ean IN (?) OR to_ean IN (?)", user_eans, user_eans)
  end

  def edc_shares_for(sharing)
    Edc::Share.where(
      from_ean: sharing.from_ean,
      to_ean: sharing.to_ean,
      shared_at: @billing.start_at..@billing.end_at
    )
  end

  def counterparty_name(sharing, is_supplier)
    other = is_supplier ? sharing.to_address : sharing.from_address
    other.user.name
  end
end
```

No pricing cascade, no fees, no peak pricing, no discounts. Just: kWh * fixed_price.

### 5.4 Receipt PDF Generation

**Adapt from wattlink's BillingPdfService (simplified):**

2 templates only:
- VAT payer receipt
- Non-VAT payer receipt

Use `wicked_pdf` same as wattlink. One partial `billings/_receipt_pdf.html.erb` with conditional VAT section.

**PDF content:**
- Header: account name, logo, receipt number
- Parties: account (issuer) + user (recipient)
- Period: start_at — end_at
- Items table: sharing pairs, kWh, price per kWh, total
- Totals: subtotal, VAT (if applicable), total
- Payment info: account number, variable symbol, QR code (rqrcode gem)
- Due date

### 5.5 Variable Symbol Generator

**Adapt from wattlink** — simple sequential numbering per account per year.

### 5.6 CSV Export

**Adapt from wattlink's BillingsCsvExporter:**

Simple export: variable symbol, user, email, period, status, amounts. Semicolon-delimited, UTF-8 with BOM.

### 5.7 Manager::BillingsController

**Adapt from wattlink's Admin::BillingsController (simplified):**

Actions:
- `index` — list all receipts, filter by user/status/period
- `new` / `create` — generate receipt for a user + period
- `show` — receipt detail with items
- `batch_create` — generate receipts for all users for a period
- `download` — PDF download
- `mark_paid` — flip status to paid
- `destroy` — delete receipt
- `export` — CSV export

**Views using DS:**
- Index: `.Table` with status `.Badge` (active/paid), user, period, amount, actions
- Show: `.Card` with receipt details, `.Table` for billing items, `.Button--primary` for PDF download
- Batch form: `.Form` with period select (previous month / custom dates), `.Button--primary` to generate
- Confirm modal: `.Modal` for batch generation confirmation

### 5.8 User Billing Views

**BillingsController (user-facing):**

```ruby
class BillingsController < AppController
  def index
    @billings = policy_scope(Billing).order(created_at: :desc).page(params[:page])
  end

  def show
    @billing = policy_scope(Billing).find(params[:id])
    authorize @billing
  end

  def download
    @billing = policy_scope(Billing).find(params[:id])
    authorize @billing
    send_data @billing.document.download, filename: @billing.pdf_filename, type: "application/pdf"
  end
end
```

**Views:**
- Index: `.Listing` with receipt cards — period, amount, status badge, download button
- Show: `.Card` with details + `.Table` for line items

### Phase 5 Tests

- Billing model: validations, status enum, amount calculations, VAT logic
- BillingItem model: validations, transaction_type enum
- BillingItemsCreator: creates items from EDC shares, handles supplier/customer sides, skips zero amounts
- Receipt PDF: generates valid PDF, includes correct data
- Variable symbol: sequential, unique per account/year
- Manager::BillingsController: CRUD, batch create, mark paid, authorization
- BillingsController (user): index scoped to user, download authorization
- System test: manager generates batch receipts, user downloads PDF

---

## Phase 6: Settings & Account Management

### 6.1 Manager::SettingsController

**Views using DS:**
- `.Form` with account name, logo upload (DS `.Form` + custom file upload partial from wattlink)
- Billing date settings: issue day, due days (number inputs)
- EDC sync status display: `.StatCard` showing last sync timestamp

### 6.2 User Settings

**Settings::UserController** (user can edit own name, email, phone, password):

Adapt from wattlink's `Settings::UsersController`.

**Views:**
- `.Form` with name, email, phone, password change section
- Password change: current password + new password + confirmation (same pattern as wattlink)

### Phase 6 Tests

- Manager::SettingsController: update account name, logo, billing dates
- Settings::UserController: update profile, change password
- System test: manager updates settings, user changes password

---

## Phase 7: Email Notifications

### 7.1 Mailers

**Adapt from wattlink's mailer patterns:**

- `UserMailer` — welcome email (when manager creates user), password reset
- `BillingMailer` — receipt notification (when receipt is generated)

Base mailer: simplified version of wattlink's `ApplicationMailer` with logo helper.

**Mailer layout:** adapt wattlink's `mailer.html.erb` — use `premailer-rails` for CSS inlining.

### 7.2 Manager Billing Email

Action on billing: "Send receipt via email" button. Same pattern as wattlink's billing email send.

### Phase 7 Tests

- UserMailer: welcome email content, password reset link
- BillingMailer: receipt notification with correct data
- Integration test: receipt email sent after batch generation

---

## Phase 8: Polish & Production Readiness

### 8.1 Error Handling

- Sentry integration (copy from wattlink)
- Custom error pages: 404, 422, 500 (adapt wattlink's public/*.html with DS styling)

### 8.2 Security

- `rack-attack` for rate limiting (copy from wattlink)
- Strong parameters everywhere
- Pundit `after_action :verify_authorized` on all controllers (copy from wattlink pattern)

### 8.3 Background Jobs

- Sidekiq configuration (copy from wattlink)
- `sidekiq-scheduler` for EDC daily sync
- Job tracker model (simplified from wattlink) — track billing generation status

### 8.4 Deployment

- Dockerfile (adapt from wattlink)
- Production database config
- Credentials setup (rails credentials:edit)
- Asset precompilation

### 8.5 Help Page

Simple static page with basic user guide. DS `.Card` components with FAQ-style content.

### Phase 8 Tests

- Full system test suite: manager complete workflow (create user → add address → create group → generate sharings → generate receipts)
- User complete workflow: login → view dashboard → view receipts → download PDF
- Authorization: user cannot access manager routes
- Edge cases: empty data, no EDC shares for period, user with no addresses

---

## Cross-Cutting: DS Usage Guidelines

LiteLink uses the design system **more consistently** than wattlink. Every view must use DS components:

| UI Element | DS Component | Not Allowed |
|---|---|---|
| Any list of items | `.Listing` or `.Table` | Raw `<ul>`, `<table>` without DS classes |
| Action buttons | `.Button--primary`, `.Button--secondary` | Raw `<button>`, `btn-*` without DS wrapper |
| Status indicators | `.Badge--active`, `.Badge--paid`, etc. | Raw colored text |
| Content sections | `.Card`, `.Box` | Raw `<div>` without DS container |
| Forms | `.Form`, `.Form__group`, `.Form__input` | Raw Bootstrap form classes |
| Alerts/Flash | `.Alert--success`, `.Alert--danger` | Raw Bootstrap alerts |
| Navigation | `.Nav`, `.Nav__link` | Custom nav markup |
| Metrics | `.StatCard`, `.StatCardGrid` | Custom metric markup |
| Pagination | `.Pagination` + kaminari | Raw kaminari output |
| Modals | `.Modal` | Raw Bootstrap modals |
| Icons | `icon()` helper + FontAwesome | Inline `<i>` tags |

---

## File Structure (Target)

```
app/
  assets/
    stylesheets/
      application.bootstrap.scss
      ds/                        ← copied from wattlink
      components/                ← LiteLink-specific overrides
  controllers/
    application_controller.rb
    app_controller.rb
    sessions_controller.rb
    password_resets_controller.rb
    dashboards_controller.rb
    billings_controller.rb
    manager/
      users_controller.rb
      addresses_controller.rb
      groups_controller.rb
      sharings_controller.rb
      billings_controller.rb
      settings_controller.rb
    settings/
      users_controller.rb
  helpers/
    application_helper.rb
  javascript/
    controllers/                 ← Stimulus controllers
  jobs/
    scrape/
      daily_reading_job.rb
      daily_share_job.rb
    afternoon_job.rb
  mailers/
    application_mailer.rb
    user_mailer.rb
    billing_mailer.rb
  models/
    current.rb
    account.rb
    user.rb
    address.rb
    group.rb
    group_customer.rb
    group_supplier_allocation.rb
    sharing.rb
    billing.rb
    billing_item.rb
    credential.rb
    edc/
      share.rb
      reading.rb
  policies/
    application_policy.rb
    user_policy.rb
    address_policy.rb
    billing_policy.rb
    manager/
      user_policy.rb
      address_policy.rb
      group_policy.rb
      sharing_policy.rb
      billing_policy.rb
  services/
    billing_items_creator.rb
    create_billing_pdf.rb
    create_sharings_from_group.rb
    dashboard_chart_service.rb
    billing_variable_symbol_generator.rb
    billings_csv_exporter.rb
  views/
    layouts/
      application.html.erb
      app.html.erb
      _head.html.erb
      _flash.html.erb
      _session.html.erb
      mailer.html.erb
    application/
      _top.html.erb
    sessions/
      new.html.erb
    dashboards/
      index.html.erb
    billings/
      index.html.erb
      show.html.erb
      _receipt_pdf.html.erb
    manager/
      users/
      addresses/
      groups/
      sharings/
      billings/
      settings/
      shared/
        _navigation.html.erb
    settings/
      users/
        edit.html.erb
config/
  routes.rb
  locales/
    cs.yml
    manager.cs.yml
    billings.cs.yml
    dashboards.cs.yml
db/
  migrate/
test/
  test_helper.rb
  application_system_test_case.rb
  factories.rb
  models/
  controllers/
  services/
  system/
```
