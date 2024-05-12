import {Controller} from "@hotwired/stimulus"
import FlashController from "./flash_controller";
// Load * from "@stripe/stripe-js"

// Connects to data-controller="checkout"
// eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
export default class CheckoutController extends Controller {
    static values = {
        siteUrl: String,
        authenticityToken: String,
        stripeApiKey: String,
        eventId: Number,
        ticketRequestId: Number
    }

    connect() {
        console.log('initializePayment: ticketRequestId=' + this.ticketRequestIdValue);
        let elements;

        // Stripe client instance
        const stripe = Stripe(this.stripeApiKeyValue);

        const siteUrl = this.siteUrlValue;
        const authenticityToken = this.authenticityTokenValue;
        const ticketRequestId = this.ticketRequestIdValue;
        const eventId = this.eventIdValue;
        const createPaymentUrl = `/events/${eventId}/ticket_requests/${ticketRequestId}/payments`;

        console.log('initializePayment: siteUrl=' + siteUrl);
        console.log('initializePayment: ticketRequestId=' + ticketRequestId);
        console.log('initializePayment: eventId=' + eventId);
        console.log('initializePayment: createPaymentUrl=' + createPaymentUrl);

        initialize();
        checkStatus();

        document
            .querySelector("#payment-form")
            .addEventListener("submit", handleSubmit);

        // Fetches a payment intent and captures the client secret
        async function initialize() {
            // call payment create for event, ticket request, and payment
            // will set payment to In Process
            const response = await fetch(createPaymentUrl, {
                    method: 'POST',
                    headers: {
                        "Content-Type": "application/json",
                        'X-CSRF-Token': authenticityToken
                    },
                })
            ;
            let {clientSecret} = await response.json();

            console.log("initialize Stripe clientSecret:", clientSecret);

            const appearance = {
                theme: 'stripe',
            };

            elements = stripe.elements({appearance, clientSecret});

            const paymentElementOptions = {
                layout: "tabs",
            };

            const paymentElement = elements.create("payment", paymentElementOptions);
            paymentElement.mount("#payment-element");
        }

        async function handleSubmit(e) {
            e.preventDefault();
            setLoading(true);

            const confirmUrl = `${siteUrl}${createPaymentUrl}/confirm`;
            console.log(`handleSubmit: Stripe confirmPayment, url: ${confirmUrl}`);

            const {error} = await stripe.confirmPayment({
                elements,
                confirmParams: {
                    return_url: confirmUrl,
                },
            });

            // This point will only be reached if there is an immediate error when
            // confirming the payment. Otherwise, your customer will be redirected to
            // your `return_url`. For some payment methods like iDEAL, your customer will
            // be redirected to an intermediate site first to authorize the payment, then
            // redirected to the `return_url`.
            console.log(`handleSubmit: ERROR from Stripe confirmPayment: ${error.message}`);
            if (error.type === "card_error" || error.type === "validation_error") {
                showMessage(error.message);
            } else {
                showMessage("An unexpected error occurred.");
            }

            setLoading(false);
        }

        async function checkStatus() {
            const clientSecret = new URLSearchParams(window.location.search).get(
                "payment_intent_client_secret"
            );

            if (!clientSecret) {
                return;
            }

            const {paymentIntent} = await stripe.retrievePaymentIntent(clientSecret);
            console.log(`checkStatus: paymentIntent.status: ${paymentIntent.status}`);

            switch (paymentIntent.status) {
                case "succeeded":
                    showMessage("Payment succeeded!");
                    break;
                case "processing":
                    showMessage("Your payment is processing.");
                    break;
                case "requires_payment_method":
                    showMessage("Your payment was not successful, please try again.");
                    break;
                default:
                    showMessage("Something went wrong.");
                    break;
            }
        }

        // ------- UI helpers -------
        function showMessage(messageText) {
            const messageContainer = document.querySelector("#payment-message");

            messageContainer.classList.remove("hidden");
            messageContainer.textContent = messageText;

            setTimeout(function () {
                messageContainer.classList.add("hidden");
                messageContainer.textContent = "";
            }, 4000);
        }

        // Show a spinner on payment submission
        function setLoading(isLoading) {
            if (isLoading) {
                // Disable the button and show a spinner
                document.querySelector(".submit").disabled = true;
                document.querySelector("#spinner").classList.remove("hidden");
                document.querySelector(".button-text").classList.add("hidden");
            } else {
                document.querySelector(".submit").disabled = false;
                document.querySelector("#spinner").classList.add("hidden");
                document.querySelector(".button-text").classList.remove("hidden");
            }
        }
    }
}
