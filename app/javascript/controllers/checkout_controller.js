import {Controller} from "@hotwired/stimulus"
import {loadStripe, Stripe} from "@stripe/stripe-js"

// Connects to data-controller="payments"
// eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
export default class CheckoutController extends Controller {
    static params = {
        stripPublishableKey: String,
        ticketRequestId: String
    }

    loadStripe() {
        window.alert('checkout connect');
        this.stripe = loadStripe(this.stripPublishableKey);
    }

    createPayement() {
        window.alert('checkout init payment');
        fetch("/payments", {method: 'POST', params: {ticket_request_id: this.ticketRequestId}})
            .then(response => response.text())

    }


}
