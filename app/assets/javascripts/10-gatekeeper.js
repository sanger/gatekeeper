(function(window,$,undefined) {

  /* Shared */
  $('.modal').on('shown.bs.modal', function (e) {
    // Autofocus the data-focus element on show
    document.getElementById(e.target.getAttribute('data-focus')).focus();
  })

  $('.default-input').focus();

  $('#user_swipecard').each(function(){

    $.extend(this, {
      copyToAllInputs: function() {
        $('input[name=user_swipecard]').val(this.value);
      },
      wait : function() {
        $(this).parents('.form-group').addClass('has-warning');
        $(this).prev('.form-control-feedback').addClass('glyphicon glyphicon-time');
      },
      unWait : function() {
        $(this).parents('.form-group').removeClass('has-warning has-success has-error');
        $(this).prev('.form-control-feedback').removeClass('glyphicon glyphicon-time glyphicon-ok-sign glyphicon-exclamation-sign')
      },
      request : function() {
        // Returns a promise
        return $.ajax({
          dataType: "json",
          url: '/users/search',
          data: 'user_swipecard='+this.value
        });
      },
      success : function(response) {
        $(this).parents('.form-group').removeClass('has-warning');
        $(this).parents('.form-group').addClass('has-success');
        $(this).prev('.form-control-feedback').removeClass('glyphicon-time glyphicon-exclamation-sign')
        $(this).prev('.form-control-feedback').addClass('glyphicon glyphicon-ok-sign');
        (this.onDone||$.noop)();
      },
      fail : function(response) {
        $(this).parents('.form-group').removeClass('has-warning has-success');
        $(this).parents('.form-group').addClass('has-error');
        $(this).prev('.form-control-feedback').removeClass('glyphicon-time glyphicon-ok-sign')
        $(this).prev('.form-control-feedback').addClass('glyphicon glyphicon-exclamation-sign');
        $(this).popover('show');
      }
    })

    $(this).on('blur',function(){
      // Lookup user on blur if we have content
      if (this.value !== "") {
        var text_box = this;
        text_box.copyToAllInputs();
        text_box.wait();
        text_box.request().then(
          //success
          function(response){ text_box.success(response); },
          // fail
          function(response){ if (response.status==404) {
            text_box.fail(response);
          } else {
            otherError(response);
          } }
        );
      };
    }).blur();

    $(this).on('focus',function(){this.unWait();});

    $(this).on("keydown", function(e) {
    /* We don't take tab index into account here */
    var code,elements
    code=e.charCode || e.keyCode;
    if (code==13) {
      e.preventDefault();
      elements = $('input')
      elements[elements.index(this)+1].focus()
      return false;
    }

  });

  });

})(window,jQuery,undefined)

