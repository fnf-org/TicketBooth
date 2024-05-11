import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payments"
// eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
export default class CheckoutController extends Controller {
    static values = {
        ticketRequestId: String
    }

    connect() {
        // window.alert('ticketRequestId: ' + this.ticketRequestIdValue);
        this.element.dataset['action'] = 'submit->disable#handleSubmit'

        let elements;
        let ticketRequestId;
        let stripePaymentId;
        ticketRequestId = this.ticketRequestIdValue;

        initialize();
        checkStatus();

        // XXX Not sure how to break up the connect into separate areas so calling this here is easy?
        this.element.addEventListener("submit", handleSubmit);

        // document
        //     .querySelector("#payment-form")

        // window.alert('checkout_controller init payment');

        // Fetches a payment intent and captures the client secret
        async function initialize() {
            const response = await fetch('/payments', {
                method: 'POST',
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({ticket_request_id: ticketRequestId}),
            });

            const {clientSecret, stripePaymentId} = await response.json();
            console.log("Stripe clientSecret:", clientSecret);
            console.log("stripePaymentId:", stripePaymentId);

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

        async function handleSubmit() {
            setLoading(true);

            console.log("handleSubmit: Stripe confirmPayment");

            const { error } = await stripe.confirmPayment({
                elements,
                confirmParams: {
                    // XXX need to generate URL to go to payments/confirm to finalize
                    return_url: `http://localhost:8080/payments/confirm?stripe_payment_id=${stripePaymentId}`,
                },
            });

            // This point will only be reached if there is an immediate error when
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
                document.querySelector("#submit").disabled = true;
                document.querySelector("#spinner").classList.remove("hidden");
                document.querySelector("#button-text").classList.add("hidden");
            } else {
                document.querySelector("#submit").disabled = false;
                document.querySelector("#spinner").classList.add("hidden");
                document.querySelector("#button-text").classList.remove("hidden");
            }
        }
    }
}
