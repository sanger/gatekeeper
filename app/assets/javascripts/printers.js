// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function (window, $, undefined) {
  var otherError;
  // Basic Error Handling
  otherError = function (response) {
    var message, text;
    message = $(".hidden .unknown-error").clone();
    text =
      (response.responseJSON || [])["error"] ||
      message.children(".critical-error-message").text();
    message.children(".critical-error-message").text(text);
    $("#flash-holder").append(message);
  };

  /* Ideally this would go elsewhere, but then I'd either pollute the global namespace,
     or need to add dependency management */
  BarcodePrinter = function (form, type) {
    this.form = $(form);
    this.form.on("submit", this.formSubmit());
    this.type = type || this.type;
    this.form.find(this.remove()).hide();
    this.form.find(this.show()).show();
    this.form.find("select").val($(this.show()).val());
  };
  BarcodePrinter.prototype = {
    formSubmit: function () {
      var print = this;
      return function (e) {
        e.preventDefault();
        print.form.find("button").attr("disabled", "disabled");
        $.ajax({
          type: "POST",
          dataType: "json",
          url: print.form[0].action,
          data: print.form.serialize(),
        }).then(print.pass(), print.fail());
      };
    },
    fail: function () {
      var print = this;
      return function (response) {
        console.log(response);
        otherError();
      };
    },
    pass: function () {
      var print = this;
      return function (response) {
        print.form.find("button").attr("disabled", false);
        print.form.find(".bc-feedback").append(print.message(response));
      };
    },
    message: function (response) {
      var guide, box;
      guide = {
        success: ["success", "glyphicon-ok"],
        error: ["danger", "glyphicon-exclamation-sign"],
      };
      box = $(document.createElement("div"));
      $.each(response, function (status, message) {
        span = $(document.createElement("span")).addClass(
          "glyphicon " + guide[status][1],
        );
        box
          .addClass("alert alert-" + guide[status][0])
          .append(span)
          .append(" " + message);
      });
      return box;
    },
    remove: function () {
      return this.type === "plate" ? ".tube-printer" : ".plate-printer";
    },
    show: function () {
      return "." + this.type + "-printer";
    },
    type: "plate",
  };

  $(".barcode-printing-form").each(function () {
    new BarcodePrinter(this);
  });
})(window, jQuery, undefined);
