import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"
import "jquery"
import Rails from "@rails/ujs"

window.$ = jQuery
window.bootstrap = bootstrap
Rails.start()
