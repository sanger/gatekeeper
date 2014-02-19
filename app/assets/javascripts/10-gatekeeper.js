(function(window,$,undefined) {

  /* Shared */
  $('.modal').on('shown.bs.modal', function (e) {
    // Autofocus the data-focus element on show
    document.getElementById(e.target.getAttribute('data-focus')).focus();
  })

  $('.default-input').focus();

})(window,jQuery,undefined)

