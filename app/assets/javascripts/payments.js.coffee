jQuery ->
  if Stripe? # Load if we're on a page that requires Stripe
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
    payment.setupForm()

payment =
  setupForm: ->
    $('#new_payment').submit ->
      $('input[type=submit]').attr('disabled', true)
      if $('#card_number').length
        payment.processCard()
        false
      else
        true

    $('.donation-option input[type=radio]').on('change', ( ->
      $totalPrice = $('#total_price')
      $totalFee = $('#total_fee')
      amount = parseFloat($(this).val(), 10) +
               parseFloat($totalPrice.data('price'), 10)
      $totalPrice.text('$' + amount.toFixed(2))
      $totalFee.text('$' + payment.extraFee(amount).toFixed(2))
    ))

    # EALD Form is separate
    $('#new_eald_payment').submit ->
      console.log('Submitting...')
      $('input[type=submit]').attr('disabled', true)
      console.log('What')
      console.log($('#card_number').length)
      if $('#card_number').length
        payment.processCard()
        false
      else
        true

    $('#eald_payment_early_arrival_passes, #eald_payment_late_departure_passes').on('change mouseup', ( ->
      $ealdPrice= $('#eald_total_price')
      $ealdFee = $('#eald_fee')
      $earlyPasses = $('#eald_payment_early_arrival_passes')
      $latePasses = $('#eald_payment_late_departure_passes')

      price = parseFloat($earlyPasses.val(), 10) * parseFloat($earlyPasses.data('default-price')) +
              parseFloat($latePasses.val(), 10) * parseFloat($latePasses.data('default-price'))

      $ealdPrice.text('$' + price.toFixed(2))
      $ealdFee.text('$' + payment.extraFee(price).toFixed(2))
    ))

  extraFee: (amount) ->
    stripeRate = 0.029 # 2.9% per transaction
    stripeFee = 0.30   # +30 cents per transaction

    if amount == 0
      0
    else
      fee = (amount * stripeRate + stripeFee) / (1 - stripeRate)
      Math.ceil(fee * 100) / 100 # Round up to the nearest cent

  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Stripe.createToken(card, payment.handleStripeResponse)

  handleStripeResponse: (status, response) ->
    if status == 200
      $('#stripe_card_token').val(response.id)
      $('form')[0].submit()
    else
      $('#stripe-error').text(response.error.message)
      $('input[type=submit]').attr('disabled', false)
