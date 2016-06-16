// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function(window,$,undefined) {

  $('#all-to-release').on('click',function(){
    $('.pending-decision').val('release')
  })
  $('#all-to-fail').on('click',function(){
    $('.pending-decision').val('fail')
  })


  $(document).ready(function() {
    function handleError(data) {
      var node = $(["<div class='alert alert-danger'>",
      " <button type='button' class='close' data-dismiss='alert' aria-label='Close'>",
      "    <span aria-hidden='true'>&times;</span>",
      " </button>", data.error, "</div>"].join(""));
      $(document.body).prepend(node);
    }

    function handleSuccess(data) {
      data.forEach(function(obj,pos){
        $("[data-lot-uuid="+obj.lot.uuid+"]").html(obj.lot.decision);
      });
    }

    var spinnerTemplate = "<span class='spinner'><i class='icon-spin icon-refresh glyphicon glyphicon-refresh spin'></i></span>&nbsp;";
    $('[data-lot-uuid] button').addClass('has-spinner').prepend(spinnerTemplate).click(function(e) {
      $('.spinner', e.target).show();
    });

    $('form').on('ajax:complete', function() { $('.spinner', this).hide();});

    $('#batch-release-all-lots').on('click', function(event) {
      $("[data-lot-uuid] button[value=release]").each(function(pos, n) { n.click();});
    });

    $('#batch-fail-all-lots').on('click', function(event) {
      $("[data-lot-uuid] button[value=fail]").each(function(pos, n) { n.click();});
    });

    $("#gk-new-qc-decision-page").on("ajax:success", function(e, data, status, xhr) {
      if (typeof data.error !== 'undefined') {
        handleError(data);
      } else {
        handleSuccess(data);
      }
    }).on("ajax:error", function(e, xhr, status, error) {
      var data = xhr.responseJSON;
      if (typeof data.error !== 'undefined') {
        handleError(data);
      }
    });
  });


})(window,jQuery,undefined)

