(function(window,$,undefined) {

  /* Shared */
  $('.modal').on('shown.bs.modal', function (e) {
    // Autofocus the data-focus element on show
    document.getElementById(e.target.getAttribute('data-focus')).focus();
  })

  $('.default-input').focus();

  $('#user_swipecard').on("keydown", function(e) {
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

})(window,jQuery,undefined)

