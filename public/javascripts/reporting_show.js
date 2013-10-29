$(document).ready(function() {
  $(".reportingEmailPdf").click(function(e) {
    $(this).parent().find('.reportingEmailPdfDiv').first().show();
    e.preventDefault();
  });
  $(".reportingEmailCsv").click(function(e) {
    $(this).parent().find('.reportingEmailCsvDiv').first().show();
    e.preventDefault();
  });
});
