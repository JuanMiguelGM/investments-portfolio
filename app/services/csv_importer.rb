# frozen_string_literal: true

require "csv"

class CsvImporter
  Result = Struct.new(:success, :snapshots_imported, :contributions_imported, :errors)

  # Maps CSV columns to policy slugs
  POLICY_COLUMNS = {
    "fondo-1" => { value: "Valor Fondo 1", delta: "Delta Fondo 1", monthly: "Delta Mensual Fondo 1",
                   contribution: "Aportado Fondo 1", cumulative_contributed: "Fondo 1 aportado" },
    "fondo-2" => { value: "Valor Fondo 2", delta: "Delta Fondo 2", monthly: "Delta Mensual Fondo 2",
                   contribution: "Aportado Fondo 2", cumulative_contributed: "Fondo 2 aportado" },
    "pp" => { value: "Valor PP", delta: "Delta PP", monthly: "Delta Mensual PP",
              contribution: "Aportado PP", cumulative_contributed: "PP aportado" }
  }.freeze

  def initialize(file_path)
    @file_path = file_path
    @errors = []
  end

  def call
    validate_file!
    return failure_result if @errors.any?

    snapshots_count = 0
    contributions_count = 0

    parse_csv.each do |row|
      date = parse_date(row["Fecha"])
      next unless date

      POLICY_COLUMNS.each do |slug, columns|
        policy = find_policy(slug)
        next unless policy

        snapshots_count += import_snapshot(policy, date, row, columns)
        contributions_count += import_contribution(policy, date, row, columns)
      end
    end

    Result.new(
      success: @errors.empty?,
      snapshots_imported: snapshots_count,
      contributions_imported: contributions_count,
      errors: @errors
    )
  end

  private

  def validate_file!
    @errors << "File not found: #{@file_path}" unless File.exist?(@file_path)
  end

  def failure_result
    Result.new(success: false, snapshots_imported: 0, contributions_imported: 0, errors: @errors)
  end

  def parse_csv
    CSV.read(@file_path, headers: true, encoding: "bom|utf-8")
  end

  def find_policy(slug)
    @policies_cache ||= {}
    @policies_cache[slug] ||= Policy.find_by(slug: slug) || begin
      @errors << "Policy not found: #{slug}" unless @policies_cache.key?(slug)
      nil
    end
  end

  def parse_date(date_str)
    return nil if date_str.blank?

    parts = date_str.strip.split("/")
    Date.new(parts[1].to_i, parts[0].to_i, 1)
  rescue Date::Error, NoMethodError
    @errors << "Invalid date: #{date_str}"
    nil
  end

  def parse_euro(value)
    return nil if value.blank?

    cleaned = value.to_s.gsub(/[€\s]/, "").strip
    return nil if cleaned.empty?

    # Handle both "1.234,56" (euro format) and "1234" or "1234.56" (raw numbers)
    if cleaned.include?(",")
      cleaned.delete(".").tr(",", ".").to_d
    else
      cleaned.to_d
    end
  end

  def import_snapshot(policy, date, row, columns)
    total_value = parse_euro(row[columns[:value]])
    return 0 unless total_value

    total_contributed = parse_euro(row[columns[:cumulative_contributed]])
    total_delta = parse_euro(row[columns[:delta]])
    monthly_change = parse_euro(row[columns[:monthly]])

    PolicySnapshot.find_or_initialize_by(policy: policy, snapshot_date: date).tap do |snapshot|
      snapshot.update!(
        total_value: total_value,
        total_contributed: total_contributed,
        total_delta: total_delta,
        monthly_change: monthly_change
      )
    end

    1
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Snapshot error for #{policy.slug} on #{date}: #{e.message}"
    0
  end

  def import_contribution(policy, date, row, columns)
    amount = parse_euro(row[columns[:contribution]])
    return 0 unless amount&.positive?

    Contribution.find_or_initialize_by(policy: policy, contribution_date: date).tap do |contribution|
      contribution.update!(amount: amount)
    end

    1
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Contribution error for #{policy.slug} on #{date}: #{e.message}"
    0
  end
end
