import { Controller } from "@hotwired/stimulus"
import "chart.js/auto"

export default class extends Controller {
  static values = {
    labels: Array,
    consumption: Array,
    production: Array,
    sharing: Array
  }

  connect() {
    this.renderChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  renderChart() {
    const ctx = this.element.querySelector("canvas")
    if (!ctx) return

    const datasets = []

    if (this.hasConsumptionValue && this.consumptionValue.some(v => v > 0)) {
      datasets.push({
        label: "Spotřeba",
        data: this.consumptionValue,
        backgroundColor: "rgba(239, 68, 68, 0.6)",
        borderColor: "rgba(239, 68, 68, 1)",
        borderWidth: 1,
        borderRadius: 4,
        type: "bar"
      })
    }

    if (this.hasProductionValue && this.productionValue.some(v => v > 0)) {
      datasets.push({
        label: "Výroba",
        data: this.productionValue,
        backgroundColor: "rgba(34, 197, 94, 0.6)",
        borderColor: "rgba(34, 197, 94, 1)",
        borderWidth: 1,
        borderRadius: 4,
        type: "bar"
      })
    }

    if (this.hasSharingValue && this.sharingValue.some(v => v > 0)) {
      datasets.push({
        label: "Sdílení",
        data: this.sharingValue,
        backgroundColor: "rgba(251, 191, 36, 0.3)",
        borderColor: "rgba(251, 191, 36, 1)",
        borderWidth: 2,
        tension: 0.3,
        fill: true,
        type: "line",
        pointRadius: 3,
        pointBackgroundColor: "rgba(251, 191, 36, 1)"
      })
    }

    this.chart = new Chart(ctx, {
      type: "bar",
      data: {
        labels: this.labelsValue,
        datasets: datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          intersect: false,
          mode: "index"
        },
        plugins: {
          legend: {
            position: "top",
            labels: {
              color: "rgba(255, 255, 255, 0.7)",
              font: { family: "Manrope", size: 12 },
              padding: 16,
              usePointStyle: true
            }
          },
          tooltip: {
            backgroundColor: "rgba(0, 0, 0, 0.8)",
            titleFont: { family: "Manrope" },
            bodyFont: { family: "Manrope" },
            callbacks: {
              label: function(context) {
                return context.dataset.label + ": " + context.parsed.y.toFixed(2) + " kWh"
              }
            }
          }
        },
        scales: {
          x: {
            ticks: {
              color: "rgba(255, 255, 255, 0.5)",
              font: { family: "Manrope", size: 11 },
              maxRotation: 45
            },
            grid: {
              color: "rgba(255, 255, 255, 0.05)"
            }
          },
          y: {
            beginAtZero: true,
            ticks: {
              color: "rgba(255, 255, 255, 0.5)",
              font: { family: "Manrope", size: 11 },
              callback: function(value) {
                return value + " kWh"
              }
            },
            grid: {
              color: "rgba(255, 255, 255, 0.05)"
            }
          }
        }
      }
    })
  }
}
