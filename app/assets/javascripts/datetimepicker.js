// Initial all datetimepickers on the page, if there are any
$('.input-datetimepicker').each(function(index, el) {
  var $el = $(el),
      date = $el.data('date');

  $el.datetimepicker({
    format: 'dd/MM/yyyy hh:mm:ss',
    pick12HourFormat: true,
    pickSeconds: false,
    format: 'yyyy/MM/dd hh:mm:ss'
  });

  // Rails returns a UTC date, so need to convert it to local time
  if (date) {
    $el.data('datetimepicker').setLocalDate(new Date(date));
  }
});
