import {Controller} from "@hotwired/stimulus"
import {loadStripe, Stripe} from "@stripe/stripe-js"

// Connects to data-controller="payments"
// eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
export default class CheckoutController extends Controller {
    // var stripe;
    // var stripeKey;
    // var controller;

    connect() {
        window.alert('checkout connected');
        this.stripeKey = this.element.getAttribute('data-stripe-publishable-key');
        this.stripe = loadStripe({publishableKey: this.stripeKey});
        this.controller = this;
    }

    // setupForm(): void {
    //     const controller = this;
    //
    // }

    initializeForm() {
        let roleExplanationField = $('textarea[name="payment[role_explanation]"]')
        roleExplanationField.toggleClass('hidden', true);
    }
}
