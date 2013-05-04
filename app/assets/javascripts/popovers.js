(function($) {
  var $popupMarkers = $('.help-popover');

  $popupMarkers.popover({
    trigger: 'manual'
  }).on('click', function(e) {
    var $popover = $(this);
    $popover.popover('toggle');
    e.preventDefault();
  });
})(jQuery);
