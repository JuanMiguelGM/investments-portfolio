# frozen_string_literal: true

class HoldingsController < ApplicationController
  def edit
    @policy = find_policy
    @funds = available_funds_for(@policy)
    ensure_holdings_exist
    @holdings = @policy.holdings.includes(:fund).order("funds.name")
  end

  def update
    @policy = find_policy

    ActiveRecord::Base.transaction do
      holdings_params.each do |holding_params|
        holding = @policy.holdings.find_or_initialize_by(fund_id: holding_params[:fund_id])
        holding.update!(units: holding_params[:units], units_as_of_date: Date.current)
      end
    end

    redirect_to policy_path(@policy.slug), notice: "Holdings updated successfully"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to edit_holding_path(@policy), alert: "Error updating holdings: #{e.message}"
  end

  private

  def holdings_params
    params.require(:holdings).map do |h|
      h.permit(:fund_id, :units)
    end
  end

  def find_policy
    Policy.find_by(id: params[:id]) || Policy.find_by!(slug: params[:id])
  end

  def available_funds_for(policy)
    policy.pension? ? Fund.where(yahoo_ticker: nil).ordered : Fund.auto_fetch.ordered
  end

  def ensure_holdings_exist
    @funds.each do |fund|
      @policy.holdings.find_or_create_by!(fund: fund) do |holding|
        holding.units = 0
      end
    end
  end
end
