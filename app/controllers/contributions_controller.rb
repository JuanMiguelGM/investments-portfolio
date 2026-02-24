# frozen_string_literal: true

class ContributionsController < ApplicationController
  def new
    @contribution = Contribution.new(
      policy_id: params[:policy_id],
      contribution_date: params[:contribution_date],
      amount: params[:amount]
    )
    @policies = Policy.active.ordered
  end

  def create
    @contribution = Contribution.new(contribution_params)

    if @contribution.save
      redirect_to policy_path(@contribution.policy.slug), notice: "Contribution recorded"
    else
      @policies = Policy.active.ordered
      render :new, status: :unprocessable_content
    end
  end

  private

  def contribution_params
    params.expect(contribution: %i[policy_id contribution_date amount])
  end
end
