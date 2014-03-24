// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function(window,$,undefined) {

  $('#all-to-release').on('click',function(){
    $('.pending-decision').val('release')
  })
  $('#all-to-fail').on('click',function(){
    $('.pending-decision').val('fail')
  })

})(window,jQuery,undefined)

