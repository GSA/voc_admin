$(document).ready(function() {
  $("#newWidgetLink").click(function() {
    $('#dashboardModalShownDiv').html($('#dashboardModalDiv').html());

    $("#dashboardModalShownDiv").modal({
      escClose: true,
      modal: true,
      onClose: function() {
        $.modal.close();
        $("#dashboardModalShownDiv").html("");
      }
    });

    $('#dashboardModalShownDiv').show();
  });

  function addWidgetToDashboard() {
    var li = document.createElement("li");
    var se_id = document.create_element("input");
    se_id.attr("type", "hidden");
    se_id.attr("name", "dashboard[dashboard_elements_attributes][][survey_element_id]");
    se_id.attr("value", $("#dashboardModalShownDiv #survey_element_id option:selected").val());
    var se_text = $("#dashboardModalShownDiv #survey_element_id option:selected").text();
    li.append(se_id, se_text);
    $("#dashboardElementsList").append(li);
  };
});
