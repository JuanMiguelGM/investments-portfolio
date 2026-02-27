import { Controller } from "@hotwired/stimulus"

// Color palette: Indigo, Emerald, Amber, Rose, Violet, Cyan
const COLORS = [
  "rgb(79, 70, 229)",
  "rgb(16, 185, 129)",
  "rgb(245, 158, 11)",
  "rgb(244, 63, 94)",
  "rgb(139, 92, 246)",
  "rgb(6, 182, 212)"
]

// Crosshair plugin — dashed indigo vertical line on hover
const crosshairPlugin = {
  id: "crosshair",
  afterDraw(chart) {
    const tooltip = chart.tooltip
    if (!tooltip || !tooltip.getActiveElements().length) return

    const { ctx } = chart
    const x = tooltip.caretX
    const topY = chart.scales.y.top
    const bottomY = chart.scales.y.bottom

    ctx.save()
    ctx.beginPath()
    ctx.setLineDash([4, 4])
    ctx.lineWidth = 1
    ctx.strokeStyle = "rgba(79, 70, 229, 0.4)"
    ctx.moveTo(x, topY)
    ctx.lineTo(x, bottomY)
    ctx.stroke()
    ctx.restore()
  }
}

function formatEuro(value) {
  if (Math.abs(value) >= 1000) {
    const k = value / 1000
    return `\u20AC${k.toLocaleString("de-DE", { minimumFractionDigits: 1, maximumFractionDigits: 1 })}k`
  }
  return `\u20AC${value.toLocaleString("de-DE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
}

function formatEuroFull(value) {
  return `\u20AC${value.toLocaleString("de-DE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
}

// Normalize the 3 data shapes into { labels: [...], datasets: [{name, data}] }
function normalizeData(raw, multiSeries) {
  // Shape A (dashboard): [{name: "Total", data: {"Mar 2019": 1234}}, ...]
  if (Array.isArray(raw) && raw.length > 0 && raw[0].name !== undefined) {
    const labels = Object.keys(raw[0].data)
    const datasets = raw.map((series) => ({
      name: series.name,
      data: labels.map((l) => series.data[l] ?? null)
    }))
    return { labels, datasets }
  }

  // Shape C (fund): [["01/03/2024", 45.67], ...]
  if (Array.isArray(raw) && raw.length > 0 && Array.isArray(raw[0])) {
    const labels = raw.map((pair) => pair[0])
    const data = raw.map((pair) => pair[1])
    return { labels, datasets: [{ name: null, data }] }
  }

  // Shape B (policy): {"Mar 2019": 1234, ...}
  if (typeof raw === "object" && !Array.isArray(raw)) {
    const labels = Object.keys(raw)
    const data = labels.map((l) => raw[l])
    return { labels, datasets: [{ name: null, data }] }
  }

  return { labels: [], datasets: [] }
}

function buildGradient(ctx, chartArea, rgbColor) {
  const gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom)
  gradient.addColorStop(0, rgbColor.replace("rgb(", "rgba(").replace(")", ", 0.25)"))
  gradient.addColorStop(1, rgbColor.replace("rgb(", "rgba(").replace(")", ", 0.01)"))
  return gradient
}

export default class extends Controller {
  static values = { data: String, multiSeries: { type: Boolean, default: false } }
  static targets = ["canvas"]

  connect() {
    if (!this.hasCanvasTarget) return

    const raw = JSON.parse(this.dataValue)
    const { labels, datasets } = normalizeData(raw, this.multiSeriesValue)
    if (labels.length === 0) return

    const showLegend = this.multiSeriesValue && datasets.length > 1

    const chartDatasets = datasets.map((ds, i) => ({
      label: ds.name || "Value",
      data: ds.data,
      borderColor: COLORS[i % COLORS.length],
      backgroundColor: COLORS[i % COLORS.length],
      borderWidth: 2,
      tension: 0.35,
      fill: true,
      pointRadius: 0,
      pointHoverRadius: 5,
      pointHoverBackgroundColor: COLORS[i % COLORS.length],
      pointHoverBorderColor: "#fff",
      pointHoverBorderWidth: 2
    }))

    const config = {
      type: "line",
      data: { labels, datasets: chartDatasets },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          mode: "index",
          intersect: false
        },
        animation: {
          duration: 800,
          easing: "easeInOutQuart"
        },
        plugins: {
          legend: {
            display: showLegend,
            position: "top",
            align: "end",
            labels: {
              usePointStyle: true,
              pointStyle: "circle",
              padding: 16,
              font: { size: 12 }
            }
          },
          tooltip: {
            backgroundColor: "rgba(17, 24, 39, 0.9)",
            titleColor: "#f3f4f6",
            bodyColor: "#e5e7eb",
            borderColor: "rgba(79, 70, 229, 0.3)",
            borderWidth: 1,
            cornerRadius: 8,
            padding: 12,
            titleFont: { size: 13, weight: "bold" },
            bodyFont: { size: 12 },
            callbacks: {
              label(context) {
                const label = context.dataset.label || ""
                const value = formatEuroFull(context.parsed.y)
                return showLegend ? ` ${label}: ${value}` : ` ${value}`
              }
            }
          }
        },
        scales: {
          x: {
            grid: { display: false },
            ticks: {
              maxTicksLimit: 8,
              maxRotation: 0,
              font: { size: 11 },
              color: "#9ca3af"
            }
          },
          y: {
            beginAtZero: false,
            grid: { color: "rgba(229, 231, 235, 0.5)" },
            ticks: {
              font: { size: 11 },
              color: "#9ca3af",
              callback(value) { return formatEuro(value) }
            }
          }
        }
      },
      plugins: [crosshairPlugin]
    }

    this.chart = new window.Chart(this.canvasTarget, config)

    // Apply gradient fills after first render
    requestAnimationFrame(() => {
      const chartArea = this.chart.chartArea
      if (!chartArea) return

      this.chart.data.datasets.forEach((ds, i) => {
        ds.backgroundColor = buildGradient(
          this.canvasTarget.getContext("2d"),
          chartArea,
          COLORS[i % COLORS.length]
        )
      })
      this.chart.update("none")
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }
}
