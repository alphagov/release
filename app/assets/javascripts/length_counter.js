(function($){
  var _enableLengthCounting = function () {
    this.each(function(idx, element) {
      var $input = $(element),
          $container = $input.parents('.form-group'),
          $message = $($input.data('countMessageSelector')).hide(),
          $count = $message.find('.count'),
          threshold = $input.data('countMessageThreshold');

          console.log($input)
          console.log($container)
          console.log($message)

      if ($input.length > 0) {
        function checkLength() {
          var length = $input.val().split('').length;

          $count.text('Current length: '+length);
          if (length > threshold) {
            $container.addClass('has-error');
            $message.addClass('text-danger');
            $message.show();
          } else {
            $container.removeClass('has-error');
            $message.removeClass('text-danger');
            if (length > (0.66 * threshold)) {
              $message.show();
            }
          }
        }
        $input.bind('keyup', checkLength);
        checkLength();
      }
    })
  }
  $.fn.extend({
    enableLengthCounting: _enableLengthCounting
  });
})(jQuery);
jQuery(function($) {
  $("[data-length-counting]").enableLengthCounting();
});
