window.addEventListener("load", function() {
  (function ($) {
    const {popover} = $('.help-popover');
    popover({
      trigger: 'manual'
    }).on('click', function (e) {
      const {popover: popoverClicked} = $(this);
      popoverClicked('toggle');
      e.preventDefault();
    });
  })(jQuery);
});
