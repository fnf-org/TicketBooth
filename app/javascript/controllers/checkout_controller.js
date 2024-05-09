import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payments"
// eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
export default class CheckoutController extends Controller {
    static values = {
        stripePublishableKey: String,
        ticketRequestId: String
    }

    connect() {
        window.alert('checkout_controller connect');
        window.alert('Stripe connected');

        let elements;

        initialize();
        checkStatus();

        document
            .querySelector("#payment-form")
            .addEventListener("submit", handleSubmit);

        window.alert('checkout_controller init payment');

        // Fetches a payment intent and captures the client secret
        async function initialize() {
            fetch("/payments", {method: 'POST', params: {ticket_request_id: this.ticketRequestIdValue}})
        }

        const {clientSecret} = response.json();

        const appearance = {
            theme: 'stripe',
        };
        elements = stripe.elements({appearance, clientSecret});

        const paymentElementOptions = {
            layout: "tabs",
        };

        const paymentElement = elements.create("payment", paymentElementOptions);
        paymentElement.mount("#payment-element");

        async function handleSubmit(e) {
            e.preventDefault();
            setLoading(true);

            const {error} = await stripe.confirmPayment({
                elements,
                confirmParams: {
                    // XXX go to payments controller confirm to finalize
                    return_url: "payments/confirm",
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
