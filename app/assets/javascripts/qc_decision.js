// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function(window,$,undefined) {

  function QcDecision() {

  }

  var proto = QcDecision.prototype;

  proto.releaseAll = function(){
    $('.pending-decision').val('release')
  };

  proto.failAll = function(){
    $('.pending-decision').val('fail')
  };

  proto.handleError = function(data) {
    var node = $('#qc-error-box');
    $('span.msg', node).html(data.error);
    $(document.body).prepend(node);
    node.show();
  };

  proto.handleSuccess = function(data) {
    data.forEach(function(obj,pos){
      var section = $("td[data-lot-uuid="+obj.lot.uuid+"]");
      section.html(obj.lot.decision);
      section.prev().html("0");
      section.addClass("pull-right");
      $("button", section).remove();
    });
  };

  proto.attachHandlers = function() {
    $('#all-to-release').on('click', $.proxy(this.releaseAll, this));
    $('#all-to-fail').on('click', $.proxy(this.failAll, this));

    var spinnerTemplate = $("#spinnerTemplate");

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

    $("#gk-new-qc-decision-page").on("ajax:success", $.proxy(function(e, data, status, xhr) {
      if (typeof data.error !== 'undefined') {
        this.handleError(data);
      } else {
        this.handleSuccess(data);
      }
    }, this)).on("ajax:error", $.proxy(function(e, xhr, status, error) {
      var data = xhr.responseJSON;
      if ((typeof data !== 'undefined') && (typeof data['error'] !== 'undefined')) {
        this.handleError(data);
      }
    }, this));
  };

  $(document).ready(function() {
    var qc = new QcDecision();
    qc.attachHandlers();
  });


})(window,jQuery,undefined)

