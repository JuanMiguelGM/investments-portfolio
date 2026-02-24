# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "chartkick", to: "chartkick.js"
pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js@4.5.1/+esm"
pin "@kurkle/color", to: "https://cdn.jsdelivr.net/npm/@kurkle/color@0.3.4/+esm"
