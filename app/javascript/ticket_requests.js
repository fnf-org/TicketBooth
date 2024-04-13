window.addEventListener("load", function () {
  $('#ticket_request_user_attributes_email')
      .on('change', function (evt) {
        var $emailField = $(this),
            email = $emailField.val(),
            lookupPath = $emailField.data('lookup-url');

        $.get(lookupPath + '?email=' + email)
            .success(function () {
              $('#email-warning').removeClass('hidden');
            })
            .fail(function () {
              $('#email-warning').addClass('hidden');
            }).always(function () {
          $('#email-reset-sent').addClass('hidden');
        });
      });

  $('#password-reset-link')
      .on('click', function (evt) {
        var resetUrl = $(this).data('reset-url'),
            $emailField = $('#ticket_request_user_attributes_email'),
            email = $emailField.val();
        $.get(resetUrl + '?email=' + email)
            .success(function () {
              $('#email-warning').addClass('hidden');
              $('#email-reset-sent').removeClass('hidden');
            });
        evt.preventDefault();
      });

  $('#ticket_request_adults, #ticket_request_kids, #ticket_request_cabins, #ticket_request_early_arrival_passes, #ticket_request_late_departure_passes')
      .on('change keyup mouseup', function (evt) {
        var $numberField = $(this),
            $priceDisplay = $numberField.find('+ .inline-price'),
            quantity = $numberField.val() || 0,
            prices = $numberField.data('custom-prices') || {},
            price = prices[quantity] || $numberField.data('default-price') * quantity,
            text_price = price ? '$' + price : '';

        $priceDisplay.text(text_price);
      })
      .each(function (idx, el) {
        var $el = $(el);
        // Force update so prices reflect default values
        // (don't update disabled elements as they already have text)
        if (!$el.is(':disabled')) {
          $el.change();
        }
      });

  $('input[name="ticket_request[role]"]')
      .on('change', function (evt) {
        var $radioBtn = $(this),
            role = $radioBtn.val(),
            $roleRadioBtn = $('#ticket_request_role_' + role),
            maxTickets = $roleRadioBtn.data('max-tickets'),
            $roleExplanationField = $('textarea[name="ticket_request[role_explanation]"]'),
            $roleExplanations = $('.role-explanation'),
            $selectedRoleExplanation = $('.role-explanation.' + role),
            $ticketsField = $('input[name="ticket_request[adults]"]');

        // Set max # of tickets to limit imposed by role
        $ticketsField.attr('max', maxTickets);

        // Reduce tickets if changing role causes maximum to be exceeded
        if ($ticketsField.val() > maxTickets) {
          $ticketsField.val(maxTickets);
          $ticketsField.change();
        }

        // Show the explanation matching the selected role
        $roleExplanations.addClass('hidden');
        $selectedRoleExplanation.removeClass('hidden');

        $roleExplanationField.toggleClass('hidden', role == 'volunteer');

        // Don't require explanation if role is "Volunteer"
        $roleExplanationField.attr('required', role != 'volunteer');
      });

  $('input[name="ticket_request[car_camping]"]')
      .on('change', function (evt) {
        var $carCampingChkbx = $(this),
            carCamping = $carCampingChkbx.is(':checked'),
            $carCampingExplanationField = $('textarea[name="ticket_request[car_camping_explanation]"]');

        $carCampingExplanationField.toggleClass('hidden', !carCamping);

        // Don't require explanation if not requesting anything
        $carCampingExplanationField.attr('required', carCamping);
      });

  $('input[name="ticket_request[agrees_to_terms]"]')
      .on('change', function (evt) {
        var $agreesChkbx = $(this),
            agrees = $agreesChkbx.is(':checked');

        $('#submit-request').attr('disabled', !agrees);
      });
});
