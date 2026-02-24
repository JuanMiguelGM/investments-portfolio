# frozen_string_literal: true

module Portfolio
  class ReturnsCalculator
    PERIODS = {
      "1M" => 1.month,
      "3M" => 3.months,
      "6M" => 6.months,
      "YTD" => :ytd,
      "1Y" => 1.year,
      "3Y" => 3.years,
      "ALL" => :all
    }.freeze

    def initialize(policy: nil)
      @policy = policy
    end

    def chart_data(period: "ALL")
      start_date = start_date_for(period)
      snapshot_data(start_date).merge(live_data(start_date)) { |_date, snap_val, live_val| live_val || snap_val }
                               .sort.to_h
    end

    def fund_chart_data(period: "ALL")
      start_date = start_date_for(period)
      policies = @policy ? [@policy] : Policy.active.to_a
      holdings_by_fund = holdings_grouped_by_fund(policies)
      return [] if holdings_by_fund.empty?

      prices_by_fund = fund_prices_since(holdings_by_fund.keys.map(&:id), start_date)
      build_fund_series(holdings_by_fund, prices_by_fund)
    end

    def policy_chart_data(policy, period: "ALL")
      start_date = start_date_for(period)
      snapshots = policy.policy_snapshots.where(snapshot_date: start_date..).chronological
      data = snapshots.each_with_object({}) do |snap, hash|
        hash[snap.snapshot_date] = snap.total_value.to_f
      end

      live = live_policy_data(policy, start_date)
      data.merge(live) { |_date, _snap_val, live_val| live_val }.sort.to_h
    end

    private

    def start_date_for(period)
      case PERIODS[period]
      when :ytd
        Date.current.beginning_of_year
      when ActiveSupport::Duration
        PERIODS[period].ago.to_date
      else
        Date.new(2019, 3, 1)
      end
    end

    def snapshot_data(start_date)
      snapshots = if @policy
                    @policy.policy_snapshots.where(snapshot_date: start_date..).chronological
                  else
                    PolicySnapshot.where(snapshot_date: start_date..).chronological
                  end

      snapshots.group_by(&:snapshot_date).transform_values do |snaps|
        snaps.sum { |s| s.total_value.to_f }
      end
    end

    def live_data(start_date)
      policies = @policy ? [@policy] : Policy.active.to_a
      return {} if policies.empty?

      dates = live_dates(start_date)
      return {} if dates.empty?

      dates.each_with_object({}) do |date, hash|
        total = policies.sum { |p| policy_value_on_date(p, date) }
        hash[date] = total if total.positive?
      end
    end

    def live_policy_data(policy, start_date)
      live_dates(start_date, scope: policy.policy_snapshots).each_with_object({}) do |date, hash|
        total = policy_value_on_date(policy, date)
        hash[date] = total if total.positive?
      end
    end

    def holdings_grouped_by_fund(policies)
      Holding.with_units.where(policy: policies).includes(:fund).group_by(&:fund)
    end

    def fund_prices_since(fund_ids, start_date)
      FundNavPrice.where(fund_id: fund_ids, price_date: start_date..).order(:price_date).group_by(&:fund_id)
    end

    def build_fund_series(holdings_by_fund, prices_by_fund)
      holdings_by_fund.filter_map do |fund, fund_holdings|
        fund_prices = prices_by_fund[fund.id] || []
        next if fund_prices.empty?

        total_units = fund_holdings.sum(&:units)
        data = fund_prices.each_with_object({}) do |price, hash|
          value = (total_units * price.nav).to_f
          hash[price.price_date] = value if value.positive?
        end
        { name: fund.name, data: data }
      end
    end

    # Only return NAV price dates after the last snapshot — snapshots are
    # authoritative for history; stale NAV prices must not override them.
    def live_dates(start_date, scope: PolicySnapshot)
      last_snapshot = scope.maximum(:snapshot_date)
      cutoff = last_snapshot ? [start_date, last_snapshot + 1].max : start_date
      FundNavPrice.where(price_date: cutoff..).distinct.pluck(:price_date).sort
    end

    def policy_value_on_date(policy, date)
      policy.holdings.with_units.includes(:fund).sum do |holding|
        # Use the latest available NAV on or before the requested date so that
        # funds with infrequent price updates still contribute their last known value.
        nav = holding.fund.fund_nav_prices.where(price_date: ..date).order(price_date: :desc).pick(:nav)
        nav ? (holding.units * nav).to_f : 0
      end
    end
  end
end
