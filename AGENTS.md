# AGENTS.md — Investments Portfolio

This document provides guidance to AI coding agents working with this repository.

## What is this project?

A personal investments portfolio dashboard built with Ruby on Rails. It tracks mutual funds across insurance policies and pension plans, importing historical monthly data from CSV and fetching daily NAV prices from Yahoo Finance.

## Development Commands

### Setup
```bash
bin/setup           # Install dependencies and prepare database
bin/dev             # Start the development server (uses Procfile.dev)
bin/rails db:seed   # Seed example funds and policies
```

### Testing
```bash
bundle exec rspec                    # Run full test suite
bundle exec rspec spec/models        # Run model specs only
bundle exec rspec spec/requests      # Run request specs only
bundle exec rspec spec/services      # Run service specs only
```

### Code Quality
```bash
bundle exec rubocop                  # Run linter
bundle exec rubocop -A               # Auto-fix offenses
```

### Database
```bash
bin/rails db:migrate                 # Run pending migrations
bin/rails db:seed                    # Seed example funds and policies
bin/rails db:reset                   # Drop, create, migrate, seed
```

## Architecture Overview

- **Framework**: Ruby on Rails 8.1, Ruby 3.4.7
- **Database**: SQLite (local development, single-user app)
- **CSS**: Tailwind CSS
- **Charts**: Chartkick + Chart.js
- **Testing**: RSpec + FactoryBot + Shoulda Matchers + WebMock
- **Linting**: RuboCop + rubocop-rails + rubocop-rspec + rubocop-performance
- **Background jobs**: Solid Queue (daily price fetching at 6 pm weekdays)

### Data Model
- **Fund** — name, ISIN, Yahoo ticker (nil for manual-NAV funds), target allocation %
- **Policy** — insurance or pension policy (`policy_type` enum), unique slug
- **Holding** (fund × policy) — current units held per fund per policy
- **FundNavPrice** — daily NAV prices fetched from Yahoo Finance or entered manually
- **Contribution** — monthly contribution amounts per policy
- **PolicySnapshot** — monthly portfolio value snapshots (imported from CSV)

### Services
- `CsvImporter` — imports historical monthly data from `tmp/imports/portfolio.csv`
- `YahooFinance::Client` — Faraday HTTP client for Yahoo Finance chart API (6-hour cache)
- `YahooFinance::PriceFetcher` — fetches and upserts daily NAV prices for all auto-fetch funds
- `Portfolio::ValueCalculator` — computes current value, gains, daily change, annualized return
- `Portfolio::ReturnsCalculator` — generates time-series chart data blending snapshots + live NAVs

### Controllers
- `DashboardController` — hero metrics, portfolio line chart (Total + per-policy), policy cards, fund table
- `FundsController` — fund list with latest NAV, individual fund NAV chart
- `PoliciesController` — policy detail with value chart, holdings, contributions
- `HoldingsController` — bulk edit units per fund per policy
- `ContributionsController` — record monthly contributions
- `Admin::ImportsController` — trigger CSV import
- `Admin::PricesController` — manual trigger to fetch Yahoo Finance prices
- `Admin::NavEntriesController` — manual NAV entry for funds without a Yahoo ticker

## Coding Style

- Follow standard Ruby/Rails conventions
- Use RuboCop defaults plus `rubocop-rails` and `rubocop-rspec` extensions
- Write RSpec tests for all new code (models, requests, services)
- Keep controllers thin, push logic to models or service objects
- Use Tailwind utility classes for styling; avoid custom CSS
- Prefer `frozen_string_literal: true` magic comment in all Ruby files
- Euro formatting: `€1.234,56` format throughout

## Security

- **No personal financial data in the repository.** CSV imports live in `tmp/imports/` (gitignored). Database files live in `storage/` (gitignored).
- Seeds contain only placeholder example data — replace with your own funds in `db/seeds.rb`.
- Never commit `.env` files, credential files, or files with real holdings/units.

## Git Workflow

- Main branch: `main`
- Feature branches: `feature/<description>`
- Bug fixes: `fix/<description>`
- Write meaningful commit messages describing the "why"
