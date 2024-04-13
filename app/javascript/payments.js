import jQuery from 'jquery';
import Stripe from 'stripe';

(function () {
  let payment;

  jQuery(function () {
    if (typeof Stripe !== "undefined" && Stripe !== null) {
      Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
      return payment.setupForm();
    }
  });

  payment = {
    setupForm: function () {
      $('#new_payment').submit(function () {
        $('input[type=submit]').attr('disabled', true);
        if ($('#card_number').length) {
          payment.processCard();
          return false;
        } else {
          return true;
        }
      });

      $('.donation-option input[type=radio]').on('change', (function () {
        var $totalFee, $totalPrice, amount;
        $totalPrice = $('#total_price');
        $totalFee = $('#total_fee');
        amount = parseFloat($(this).val(), 10) + parseFloat($totalPrice.data('price'), 10);
        $totalPrice.text('$' + amount.toFixed(2));
        return $totalFee.text('$' + payment.extraFee(amount).toFixed(2));
      }));

      $('#new_eald_payment').submit(function () {
        console.log('Submitting...');
        $('input[type=submit]').attr('disabled', true);
        console.log('What');
        console.log($('#card_number').length);
        if ($('#card_number').length) {
          payment.processCard();
          return false;
        } else {
          return true;
        }
      });
      return $('#eald_payment_early_arrival_passes, #eald_payment_late_departure_passes').on('change mouseup', (function () {
        var $ealdFee, $ealdPrice, $earlyPasses, $latePasses, price;
        $ealdPrice = $('#eald_total_price');
        $ealdFee = $('#eald_fee');
        $earlyPasses = $('#eald_payment_early_arrival_passes');
        $latePasses = $('#eald_payment_late_departure_passes');
        price = parseFloat($earlyPasses.val(), 10) * parseFloat($earlyPasses.data('default-price')) + parseFloat($latePasses.val(), 10) * parseFloat($latePasses.data('default-price'));
        $ealdPrice.text('$' + price.toFixed(2));
        return $ealdFee.text('$' + payment.extraFee(price).toFixed(2));
      }));
    }, extraFee: function (amount) {
      var fee, stripeFee, stripeRate;
      stripeRate = 0.029;
      stripeFee = 0.30;
      if (amount === 0) {
        return 0;
      } else {
        fee = (amount * stripeRate + stripeFee) / (1 - stripeRate);
        return Math.ceil(fee * 100) / 100;
      }
    }, processCard: function () {
      var card;
      card = {
        number: $('#card_number').val(),
        cvc: $('#card_code').val(),
        expMonth: $('#card_month').val(),
        expYear: $('#card_year').val()
      };
      return Stripe.createToken(card, payment.handleStripeResponse);
    }, handleStripeResponse: function (status, response) {
      if (status === 200) {
        $('#stripe_card_token').val(response.id);
        return $('form')[0].submit();
      } else {
        $('#stripe-error').text(response.error.message);
        return $('input[type=submit]').attr('disabled', false);
      }
    }
  };

}).call(this);
