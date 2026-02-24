# frozen_string_literal: true

class PoliciesController < ApplicationController
  def show
    @policy = Policy.find_by!(slug: params[:slug])
    @calculator = Portfolio::ValueCalculator.new(policy: @policy)
    @returns = Portfolio::ReturnsCalculator.new(policy: @policy)
    @period = params[:period] || "ALL"
    @chart_data = @returns.policy_chart_data(@policy, period: @period).transform_keys { |d| d.strftime("%b %Y") }
    @contributions = @policy.contributions.reverse_chronological
    @holdings = @policy.holdings.includes(fund: :fund_nav_prices).with_units
  end
end
