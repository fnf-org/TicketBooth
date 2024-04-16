import jQuery from 'jquery';

(function ($) {
  const popover: JQuery<HTMLElement> = $('.help-popover');
  popover({
    trigger: 'manual'
  }).on('click', function (e) {
    const popoverClicked: JQuery<HTMLElement> = $(this);
    popoverClicked('toggle');
    e.preventDefault();
  });
})(jQuery);

(function () {
  jQuery(function () {
    $("a[rel~=popover], .has-popover").popover();
    return $("a[rel~=tooltip], .has-tooltip").tooltip();
  });

}).call(this);

$('.hover-tooltip').tooltip();
