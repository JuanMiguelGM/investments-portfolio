# frozen_string_literal: true

module Portfolio
  class ValueCalculator
    def initialize(policy: nil)
      @policy = policy
    end

    def current_value
      return Policy.active.sum { |p| self.class.new(policy: p).current_value } unless @policy

      live = holdings.sum(&:current_value)
      live.positive? ? live : snapshot_value
    end

    def total_contributed
      snapshot_contributed.positive? ? snapshot_contributed : contributions_sum
    end

    def total_gain
      current_value - total_contributed
    end

    def total_gain_pct
      return 0 if total_contributed.zero?

      ((total_gain / total_contributed) * 100).round(2)
    end

    def daily_change
      holdings.sum do |holding|
        nav_price = holding.fund.latest_nav
        next 0 unless nav_price&.daily_change && holding.units.positive?

        nav_price.daily_change * holding.units
      end
    end

    def daily_change_pct
      return 0 if current_value.zero?

      ((daily_change / current_value) * 100).round(2)
    end

    def annualized_return
      first_contribution = earliest_contribution_date
      return 0 unless first_contribution

      years = (Date.current - first_contribution).to_f / 365.25
      return 0 if years < 0.1 || total_contributed.zero?

      ratio = current_value / total_contributed
      return 0 unless ratio.positive?

      ((ratio**(1.0 / years)) - 1) * 100
    end

    def using_live_data?
      holdings.sum(&:current_value).positive?
    end

    private

    def holdings
      @holdings ||= if @policy
                      @policy.holdings.includes(fund: :fund_nav_prices).with_units
                    else
                      Holding.includes(fund: :fund_nav_prices).with_units
                    end
    end

    def latest_snapshots
      @latest_snapshots ||= if @policy
                              [@policy.latest_snapshot].compact
                            else
                              Policy.active.includes(:policy_snapshots).filter_map(&:latest_snapshot)
                            end
    end

    def snapshot_value
      latest_snapshots.sum { |s| s.total_value.to_f }
    end

    def snapshot_contributed
      latest_snapshots.sum { |s| s.total_contributed.to_f }
    end

    def contributions_sum
      scope = @policy ? @policy.contributions : Contribution.all
      scope.sum(:amount).to_f
    end

    def earliest_contribution_date
      scope = @policy ? @policy.contributions : Contribution.all
      scope.minimum(:contribution_date)
    end
  end
end
