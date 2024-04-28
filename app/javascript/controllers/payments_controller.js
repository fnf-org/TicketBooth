import {Controller} from "@hotwired/stimulus"
import {loadStripe, Stripe} from "@stripe/stripe-js"

// Connects to data-controller="payments"
export default class PaymentsController extends Controller {
    var stripe;
    var stripeKey;
    var controller;

    connect() {
        this.stripeKey = $('meta[name="stripe-key"]').attr('content') || this.element.getAttribute('data-stripe-publishable-key');
        this.stripe = loadStripe(this.stripeKey);
        this.controller = this;
    }

    setupForm(): void {
        const controller = this;

        $('#new_payment').submit(function (): boolean {
            $('input[type=submit]').attr('disabled', "true");
            if ($('#card_number').length) {
                controller.processCard();
                return false;
            } else {
                return true;
            }
        });

        $('.donation-option input[type=radio]').on('change', (function (): void {
            let totalFee: HTMLElement
            let totalPrice: HTMLElement
            let amount: number;


            totalPrice = $('#total_price').get(0)
            totalFee = $('#total_fee').get(0);
            amount = parseFloat($(this).val().toString()) + parseFloat(totalPrice.attributes["data"]('price'));
            totalPrice.text('$' + amount.toFixed(2));
            totalFee.text('$' + controller.extraFee(amount).toFixed(2));
        }));

        $('#new_eald_payment').submit(function (): boolean {
            console.log('Submitting...');
            $('input[type=submit]').attr('disabled', "true");
            console.log('What');
            if ($('#card_number').length) {
                controller.processCard();
                return false;
            } else {
                return true;
            }
        });

        $('#eald_payment_early_arrival_passes, #eald_payment_late_departure_passes').on('change mouseup', this.handlePasses());
    }

    handlePasses(): boolean {
        const controller = this;

        let ealdFee: HTMLElement;
        let ealdPrice: HTMLElement;
        let earlyPasses: HTMLElement;
        let latePasses: HTMLElement;
        let price: number;

        ealdPrice = $('#eald_total_price');
        ealdFee = $('#eald_fee');
        earlyPasses = $('#eald_payment_early_arrival_passes');
        latePasses = $('#eald_payment_late_departure_passes');

        price =
            parseFloat(earlyPasses.val().toString()) * parseFloat(earlyPasses.data('default-price')) +
            parseFloat(latePasses.val().toString()) * parseFloat(latePasses.data('default-price'));

        ealdPrice.text('$' + price.toFixed(2));

        ealdFee.text('$' + controller.extraFee(price).toFixed(2));

        return true;
    }

    extraFee(amount: number): number {
        let fee: number, stripeFee: number, stripeRate: number;
        stripeRate = 0.029;
        stripeFee = 0.30;
        if (amount === 0) {
            return 0;
        } else {
            fee = (amount * stripeRate + stripeFee) / (1 - stripeRate);
            return Math.ceil(fee * 100) / 100;
        }
    }

    processCard(): void {
        const controller = this;

        let card: {
            number: string,
            cvc: string,
            expMonth: string,
            expYear: string
        };

        card = {
            number: $('#card_number').val().toString(),
            cvc: $('#card_code').val().toString(),
            expMonth: $('#card_month').val().toString(),
            expYear: $('#card_year').val().toString()
        };

        return controller.stripe.createToken(card, controller.handleStripeResponse);
    }

    handleStripeResponse(status: number, response: any): void {
        if (status === 200) {
            $('#stripe_card_token').val(response.id);
            $('form')[0].submit();
        } else {
            $('#stripe-error').text(response.error.message);
            $('input[type=submit]').attr('disabled', false);
        }
    }
}
