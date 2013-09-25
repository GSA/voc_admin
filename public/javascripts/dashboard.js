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

    reporterType = $("#dashboardModalShownDiv #survey_element_id option:first").data("type");
    hideElementTypes();
    displayElementTypes(reporterType);
    $('#dashboardModalShownDiv').show();
    $("#dashboardModalShownDiv #element_type").val($("#dashboardModalShownDiv #element_type option[data-display='visible']").first().val());
  });

  $('#dashboardModalShownDiv #survey_element_id option').live('click', function() {
    hideElementTypes();
    displayElementTypes($(this).data("type"));
    $("#dashboardModalShownDiv #element_type").val($("#dashboardModalShownDiv #element_type option[data-display='visible']").first().val());
  });

  $('form .remove_element').click(function() {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('li').hide();
  });

  $('form .remove_pending_element').live('click', function() {
    $(this).closest('li').remove();
  });

  $('#dashboardElementsList').sortable();
});

function hideElementTypes() {
  $("#dashboardModalShownDiv #element_type option").hide();
  $("#dashboardModalShownDiv #element_type option").attr("data-display", "hidden");
}

function displayElementTypes(reporterType) {
  var dataType = "";
  switch (reporterType) {
    case "choice":
      dataType = "count_per_answer_option"
      break;
    case "text":
      dataType = "word_cloud"
  }
  $("#dashboardModalShownDiv #element_type option[data-type='" + dataType + "']").show();
  $("#dashboardModalShownDiv #element_type option[data-type='" + dataType + "']").attr("data-display", "visible");
}

function addWidgetToDashboard() {
  newId = new Date().getTime();
  idText = "#dashboard_dashboard_elements_attributes_replaceId_";
  $("#dashboardElementsList").append("<li style='display: none'></li>");
  var li = $("#dashboardElementsList li:last");
  li.html($("#dashboardElementBlank").html());
  li.find(idText + "survey_element_id").first().val($("#dashboardModalShownDiv #survey_element_id option:selected").val());
  li.find(idText + "element_type").first().val($("#dashboardModalShownDiv #element_type option:selected").val());
  li.append($("#dashboardModalShownDiv #survey_element_id option:selected").text());
  li.append(" - ");
  li.append($("#dashboardModalShownDiv #element_type option:selected").text());
  li.html(li.html().replace(/replaceId/g, newId));
  li.show();
  $.modal.close();
};
