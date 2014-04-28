$('#ticket_request_adults, #ticket_request_kids, #ticket_request_cabins')
  .on('change keyup', function(evt) {
    var $numberField = $(this),
        $priceDisplay = $numberField.find('+ .inline-price'),
        quantity = $numberField.val() || 0,
        prices = $numberField.data('custom-prices') || {},
        price = prices[quantity] || $numberField.data('default-price') * quantity,
        text_price = price ? '$' + price : '';

    $priceDisplay.text(text_price);
  })
  .each(function(idx, el) {
    var $el = $(el);
     // Force update so prices reflect default values
     // (don't update disabled elements as they already have text)
    if (!$el.is(':disabled')) {
      $el.change();
    }
  });

$('input[name="ticket_request[role]"]')
  .on('change', function(evt) {
    var $radioBtn = $(this),
        role = $radioBtn.val();
        $roleExplanation = $('textarea[name="ticket_request[role_explanation]"]');

    $roleExplanation.toggleClass('hidden', role != 'other');

    // Don't require explanation if role is not "Other"
    $roleExplanation.attr('required', function(idx, oldAttr) {
      return role == 'other';
    });
  });
