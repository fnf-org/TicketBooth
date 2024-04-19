import jQuery from 'jquery';

(function ($) {
  const popover = $('.help-popover');
  popover({
    trigger: 'manual'
  }).on('click', function (e) {
    const popoverClicked = $(this);
    popoverClicked('toggle');
    e.preventDefault();
  });
})(jQuery);

(function () {
  jQuery(function () {
    $("a[rel~=popover], .has-popover").popover;
    return $("a[rel~=tooltip], .has-tooltip").tooltip;
  });

}).call(this);

$('.hover-tooltip').tooltip();
