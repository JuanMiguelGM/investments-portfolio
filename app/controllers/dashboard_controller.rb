# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @calculator = Portfolio::ValueCalculator.new
    @returns = Portfolio::ReturnsCalculator.new
    @period = params[:period] || "ALL"
    @policies = Policy.active.ordered.includes(holdings: { fund: :fund_nav_prices })
    @funds = Fund.ordered.includes(:fund_nav_prices)
    @has_data = PolicySnapshot.exists? || Holding.with_units.exists?
    @chart_data = build_chart_data
    @pending_contributions = pending_monthly_contributions
  end

  private

  def build_chart_data
    cutoff = Date.current.beginning_of_month
    aggregate = format_chart_series(@returns.chart_data(period: @period), cutoff)
    return aggregate if @policies.empty?

    policy_series = @policies.map do |policy|
      data = format_chart_series(@returns.policy_chart_data(policy, period: @period), cutoff)
      { name: policy.name, data: data }
    end

    [{ name: "Total", data: aggregate }] + policy_series
  end

  def format_chart_series(raw, cutoff)
    raw.reject { |d, _| d >= cutoff }.transform_keys { |d| d.strftime("%b %Y") }
  end

  def pending_monthly_contributions
    prev_month_start = (Date.current - 1.month).beginning_of_month
    prev_month_end   = (Date.current - 1.month).end_of_month

    Policy.active.ordered.filter_map do |policy|
      next if policy.contributions.exists?(contribution_date: Date.current.beginning_of_month..)

      last = policy.contributions.find_by(contribution_date: prev_month_start..prev_month_end)
      next unless last

      { policy: policy, suggested_amount: last.amount, suggested_date: Date.current.beginning_of_month }
    end
  end
end
