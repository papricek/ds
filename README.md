# LiteLink

Simplified version of Wattlink for energy sharing and billing. See `PLAN.md` for the product specification.

## Setup

```bash
chruby-exec ruby-3.2.2 -- bundle install
chruby-exec ruby-3.2.2 -- bin/rails db:create db:migrate
chruby-exec ruby-3.2.2 -- bin/rails server
```

## Stack

- Ruby 3.2.2, Rails 8.0.4, PostgreSQL
- Stimulus.js + Turbo Rails + Bootstrap 5
- Sidekiq for background jobs
