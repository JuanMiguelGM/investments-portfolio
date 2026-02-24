# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contribution do
  describe "validations" do
    it { is_expected.to validate_presence_of(:contribution_date) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:policy) }
  end
end
