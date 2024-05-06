// eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
// eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
import "./controllers"
import "@hotwired/turbo-rails"
import { Application } from '@hotwired/stimulus'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }
