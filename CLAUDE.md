# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LiteLink is a simplified version of Wattlink — a Rails energy sharing and billing platform. It shares the same codebase as Wattlink, gated behind an `account.plan == "light"` flag. Czech-language UI with Czech URL paths.

See `PLAN.md` for the full product specification.

- **Ruby 3.2.2, Rails 8.0.2, PostgreSQL, Redis, Sidekiq**
- **Frontend:** Stimulus.js + Turbo Rails + Bootstrap 5 (importmap-rails, no webpack/esbuild)
- **Authorization:** Pundit (2 roles: manager, user; customer/supplier role on address)
- **Time zone:** Prague | **Default locale:** Czech (cs)

## Running Commands

Use `chruby-exec` to run all Rails/Ruby commands (system Ruby is 2.6 and won't work):

```bash
chruby-exec ruby-3.2.2 -- bin/rails server
chruby-exec ruby-3.2.2 -- bin/rails test
chruby-exec ruby-3.2.2 -- bin/rails test test/models/user_test.rb
chruby-exec ruby-3.2.2 -- bin/rails test test/models/user_test.rb:42
chruby-exec ruby-3.2.2 -- bundle exec rubocop
chruby-exec ruby-3.2.2 -- bundle exec rubocop -A
```

## Development Practices

### Rails Way

Follow Rails conventions strictly. Prefer convention over configuration:

- RESTful controllers with standard CRUD actions
- Thin controllers — business logic lives in **service objects** (`app/services/`) using the `SimpleCommand` pattern
- Models contain validations, associations, scopes, and enums only — no business logic
- Use `Current.user` and `Current.account` (set per-request), never pass user/account through params
- Use Rails helpers, concerns, and callbacks where they naturally fit
- Use ActiveRecord scopes over class methods for queries
- Use strong parameters in controllers
- Prefer Turbo Frames and Turbo Streams over custom JavaScript

### Design System

Reuse the Wattlink design system heavily. Do not invent new UI patterns:

- **BEM naming:** `.ComponentName__element--modifier` (e.g., `.Card__title--accent`)
- **CSS variables for theming:** use `var(--brand-primary)`, `var(--white-85)`, etc. from configuration.scss
- **Dark theme by default** — all components are designed for dark backgrounds
- **Bootstrap 5 utilities** for layout (flex, grid, spacing) — custom DS components for domain UI
- **Core components:** Button, Badge, Card, Table, Form, Alert, Modal, Listing, Tabs, Box, StatCard, FilterPanel
- **Font:** Manrope (Google Fonts), weights 300-700
- **DS showcase:** https://papricek.github.io/ds/
- When building new views, find the closest existing Wattlink view and follow its structure

### Testing

Every feature must have automated tests. No exceptions.

- **Framework:** Rails built-in Minitest + FactoryBot + Faker
- **Factories:** defined in `test/factories.rb`
- **Parallel execution:** `parallelize workers: :number_of_processors`
- **System tests:** Capybara + Cuprite (headless Chrome)
- **Test structure:** every test gets a fresh `@account` via `create(:account)` in setup
- Write model tests for validations, scopes, and business logic
- Write controller/integration tests for happy path + authorization
- Write system tests for critical user flows (login, dashboard, billing generation)
- Test the `account.light?` feature gating — both light and full paths

### Code Style

- **No comments in code** — strict rule, code must be self-explanatory
- **Double quotes** for strings
- **No trailing whitespace**
- Follow `rubocop-rails-omakase` style guide (`.rubocop.yml`)
- Run `rubocop -A` before committing
- Use `Current.user` (not `current_user` instance variable)
- Avoid `respond_to` blocks in controllers
- CSS: Bootstrap 5 utilities + BEM naming convention

### Feature Gating Pattern

All LiteLink-specific behavior is gated via `account.light?` / `account.full?`:

```ruby
# In controllers — skip actions or redirect
before_action :require_full_plan, only: [:contracts, :offers]

# In views — conditionally render sections
<% if Current.account.full? %>
  <%= render "advanced_filters" %>
<% end %>

# In models — role validation
validates :role, inclusion: { in: %w[manager user] }, if: -> { account&.light? }

# In routes — constrain entire namespaces
constraints ->(req) { req.env["account"]&.full? } do
  namespace :lab do
    # ...
  end
end
```

### Key Gems

| Gem | Purpose |
|-----|---------|
| `rails` 8.0.2 | Framework |
| `pg` | PostgreSQL adapter |
| `pundit` | Authorization policies |
| `sidekiq` + `sidekiq-scheduler` | Background jobs |
| `stimulus-rails` + `turbo-rails` | Frontend interactivity |
| `bootstrap` | CSS framework |
| `simple_command` | Service object pattern |
| `wicked_pdf` | PDF generation |
| `factory_bot_rails` + `faker` | Test data |
| `rubocop-rails-omakase` | Linting |
| `kaminari` | Pagination |
| `rqrcode` | QR codes on billing receipts |

### Release Flow

- **Commit** after each meaningful change automatically — don't wait for the user to ask.
- **Push** only when explicitly asked: `git push origin main`
- **Deploy** only when explicitly asked: `ssh deploy@litelink.wattlink.cz 'cd /var/www/litelink && git pull && RAILS_ENV=production bundle install && RAILS_ENV=production bin/rails db:migrate && RAILS_ENV=production bin/rails assets:precompile && sudo systemctl restart litelink'`

### Playwright / System Tests

When running Playwright or browser-based tests, start the Rails server on port 3001 (not 3000) to avoid killing the user's running dev server:

```bash
chruby-exec ruby-3.2.2 -- bin/rails server -p 3001
```

### Architecture Rules

- Multi-tenant via `Account` — always scope queries to `Current.account`
- Decorators in `app/decorators/` for presentation logic — keep models and views clean
- Mailers for all user-facing emails — never send email from controllers or models directly
- Background jobs for anything slow: billing generation, EDC sync, exports
- Use Pundit policies for all authorization checks — never use role checks inline
- I18n for all user-facing text — no hardcoded Czech strings in views or controllers
