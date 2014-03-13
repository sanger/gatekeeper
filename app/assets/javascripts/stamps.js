// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

/* TODO:
 * 1: Get rid of some of the duplication here between the sections
 */
(function(window,$,undefined) {
  var unknownError, robotSetup, stockValidator, bedValidator

  // Basic Error Handling
  unknownError = function(response) {
    $('#flash-holder').append($('.unknown-error'));
  }

  // Enforce Linear Flow (Robot)
  robotSetup = {
   user  : $.Deferred(),
   robot : $.Deferred(),
   tip   : $.Deferred()
  }

  $.when(robotSetup.user,robotSetup.robot,robotSetup.tip).then(function(){
    stockValidator.enable();
  })

  $('#user_swipecard').on('blur',function(){
    if (this.value !== "") { robotSetup.user.resolve(); };
  })

  $('#tip_lot').on('blur',function(){
    if (this.value !== "") { robotSetup.tip.resolve(); };
  }).blur();

  $('#robot_barcode').each(function(){

    $.extend(this, {
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
          url: '/robots/search',
          data: 'robot_barcode='+this.value
        });
      },
      success : function(response) {
        $(this).parents('.form-group').removeClass('has-warning');
        $(this).parents('.form-group').addClass('has-success');
        $(this).prev('.form-control-feedback').removeClass('glyphicon-time glyphicon-exclamation-sign')
        $(this).prev('.form-control-feedback').addClass('glyphicon glyphicon-ok-sign');
        bedValidator.bedSize = response.robot.bed_count;
        robotSetup.robot.resolve();
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
      // Lookup robot on blur if we have content
      if (this.value !== "") {
        var text_box;
        text_box = this;
        this.wait();
        this.request().then(
          //success
          function(response){ text_box.success(response); },
          // fail
          function(response){ if (response.status==404) {
            text_box.fail(response);
          } else {
            unknownError(response);
          } }
        );
      };
    }).blur();

    $(this).on('focus',function(){this.unWait();});

  });

  stockValidator = {
    enable: function() {
      $('#stock-gate').addClass('gated_after').removeClass('gated_before');
    },
    request: function() {
      return $.ajax({
        type: 'POST',
        dataType: "json",
        url: 'validation',
        data: $('form').serialize()+'&validate=lot'
      })
    },

    processResponse: function(response) {
      console.log('r')
      console.log(response);
      if (response.status) {
        stockValidator.pass();
      } else {
        stockValidator.addErrors(response.messages);
      }
    },

    pass: function() {
      $('#stock-information').
      html('').
      append($('.hidden .stock-success').clone());
      bedValidator.enable();
    },

    addErrors: function(messages) {
      var errorBox,i;
      errorBox = $('.hidden .stock-error').clone();
      for (i=0; i<messages.length; i++) {
        errorBox.children('ul').append($('<li>').text(messages[i]))
      }
      $('#stock-information').
      html('').
      append(errorBox);
    },

    validate: function() {
      this.wait();
      this.request().then(
        // Success
        function(response){
          stockValidator.processResponse(response.validation);
        },
        // Failure
        function(response){unknownError(response);}
      )
    },

    wait: function() {
      $('#stock-information').
      html('').
      append($('.hidden .stock-progress').clone());
    }

  }

  $('.stock_field').each(function(){

    $(this).on('blur',function(){
      if ($.grep($('.stock_field'),function(item){return item.value===""}).length==0) {
        stockValidator.validate();
      }
    })

  })

/* Bed Validation */
  bedValidator = {
    enable: function() {
      $('#bed-gate').addClass('gated_after').removeClass('gated_before');
      this.enableInput();
    },
    addBed: function(bed_barcode,plate_barcode) {
      $('#scanned-beds').append(this.buildBed(bed_barcode,plate_barcode));
      this.checkNumber();
    },
    buildBed: function(bed_barcode,plate_barcode) {
      var bed;
      bed = $('.hidden .bed').clone();
      bed.children('.bed-barcode').text(bed_barcode);
      bed.children('.plate-barcode').text(plate_barcode);
      bed.children('.close').on('click',function(){
        bed.detach();
        bedValidator.checkNumber();
      })
      bed.append(
        $('<input>').attr({
          type: 'hidden',
          name: 'beds['+bed_barcode+']',
          value: plate_barcode
        })
      );
      return bed;
    },
    checkNumber: function(){
      if ($('#scanned-beds').children('.bed').length >= this.bedSize) {
        this.disableInput();
        this.wait();
        this.validate();
      } else {
        $('.stamp-btn').attr('disabled','disabled');
        this.enableInput();
      }
    },
    enableInput: function(){
      $('.bed_field').attr('disabled',false)
    },
    disableInput: function(){
      $('.bed_field').attr('disabled','disabled')
    },
    validate: function(){
      this.wait();
      this.request().then(
        // Success
        function(response){
          bedValidator.processResponse(response.validation);
        },
        // Failure
        function(response){unknownError(response);}
      )
    },
    request: function() {
      return $.ajax({
        type: 'POST',
        dataType: "json",
        url: 'validation',
        data: $('form').serialize()+'&validate=full'
      })
    },
    wait: function() {
      $('#bed-information').
      html('').
      append($('.hidden .bed-progress').clone());
      $('.stamp-btn').attr('disabled','disabled');
    },
    processResponse: function(response) {
      if (response.status) {
        this.pass();
      } else {
        this.addErrors(response.messages);
      }
    },

    pass: function() {
      $('#bed-information').
      html('').
      append($('.hidden .bed-success').clone());
      $('.stamp-btn').attr('disabled',false);
    },

    addErrors: function(messages) {
      var errorBox,i;
      errorBox = $('.hidden .bed-error').clone();
      for (i=0;i<messages.length;i++) {
        errorBox.children('ul').append($('<li>').text(messages[i]))
      }
      $('#bed-information').
      html('').
      append(errorBox);
    },
    bedSize: 10
  };

  $('#scan_bed').on('blur',function(event){
    if ($('#scan_plate').val()!=="") {
      bedValidator.addBed($('#scan_bed').val(), $('#scan_plate').val())
      $('.bed_field').val('');
    }
    $('#scan_plate').focus();
  })


})(window,jQuery,undefined)

