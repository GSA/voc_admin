$(document).ready(function() {
  displayOptions();
  $("#recurring_report_frequency").change(function() {
    displayOptions();
  });
});

function displayOptions() {
  $('.dateOption').hide();
  var frequency = $("#recurring_report_frequency").find("option:selected").val();
  switch (frequency) {
    case "weekly":
      $('#dayOfWeek').show();
      break;
    case "monthly":
      $('#dayOfMonth').show();
      break;
    case "quarterly":
      $('#month').show();
      $('#dayOfMonth').show();
  }
}
