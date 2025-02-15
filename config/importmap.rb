# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "daisyui", to: "https://cdn.jsdelivr.net/npm/daisyui@5.0.0-beta.8/+esm"
pin_all_from "app/javascript/controllers", under: "controllers"
