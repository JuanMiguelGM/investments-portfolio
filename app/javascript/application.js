// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Chartkick needs window.Chart. Import Chart.js and expose it globally before importing chartkick.
import { Chart, registerables } from "chart.js"
Chart.register(...registerables)
window.Chart = Chart

import "chartkick"
