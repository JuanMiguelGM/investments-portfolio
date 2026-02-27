# frozen_string_literal: true

module ApplicationHelper
  def format_euro(amount)
    return "---" if amount.nil?

    number_to_currency(amount, unit: "\u20AC", format: "%u%n", delimiter: ".", separator: ",")
  end

  def format_pct(value)
    return "---" if value.nil?

    "#{number_with_precision(value, precision: 2, delimiter: ".", separator: ",")}%"
  end

  def gain_color(value)
    return "text-gray-500" if value.nil? || value.zero?

    value.positive? ? "text-green-600" : "text-red-600"
  end

  def gain_sign(value)
    return "" if value.nil? || value.zero?

    value.positive? ? "+" : ""
  end

  def period_links(current_period, path_method = :root_path)
    periods = %w[1M 3M 6M YTD 1Y 3Y ALL]
    periods.map do |period|
      active = period == current_period
      css = active ? "bg-indigo-600 text-white" : "bg-white text-gray-700 hover:bg-gray-100"
      link_to period, send(path_method, period: period), class: "px-3 py-1 rounded-md text-sm font-medium #{css}"
    end.join(" ").html_safe # rubocop:disable Rails/OutputSafety
  end

  def allocation_bar(pct)
    return "" if pct.nil? || pct.zero?

    width = [pct, 100].min
    tag.span(class: "inline-block h-2 rounded-full bg-indigo-400 align-middle ml-2", style: "width: #{width}%")
  end

  def policy_accent_class(policy)
    policy.pension? ? "border-l-4 border-emerald-400" : "border-l-4 border-indigo-400"
  end
end
