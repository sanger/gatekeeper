(function(window,$,undefined) {

  /* Shared */
  $('.modal').on('shown.bs.modal', function (e) {
    // Autofocus the data-focus element on show
    console.log('called');
    console.log(e.target.getAttribute('data-focus'));
    console.log(document.getElementById(e.target.getAttribute('data-focus')));
    document.getElementById(e.target.getAttribute('data-focus')).focus();
  })

})(window,jQuery,undefined)
