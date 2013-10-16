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
    hideDisplayTypes();
    displayDisplayTypes(reporterType);
    $('#dashboardModalShownDiv').show();
    $("#dashboardModalShownDiv #display_type").val($("#dashboardModalShownDiv #display_type option[data-display='visible']").first().val());
  });

  $('#dashboardModalShownDiv #survey_element_id option').live('click', function() {
    hideDisplayTypes();
    displayDisplayTypes($(this).data("type"));
    $("#dashboardModalShownDiv #display_type").val($("#dashboardModalShownDiv #display_type option[data-display='visible']").first().val());
  });

  $('form .remove_element').click(function() {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('li').hide();
  });

  $('form .remove_pending_element').live('click', function() {
    $(this).closest('li').remove();
  });

  $('#dashboardElementsList').sortable();
  $('.datepicker').datepicker();
});

function hideDisplayTypes() {
  $("#dashboardModalShownDiv #display_type option").hide();
  $("#dashboardModalShownDiv #display_type option").attr("data-display", "hidden");
}

function displayDisplayTypes(reporterType) {
  var dataTypes = [];
  switch (reporterType) {
    case "choice-multiple":
      dataTypes = ["bar"]
      break;
    case "choice-single":
      dataTypes = ["bar", "pie"]
      break;
    case "text":
      dataTypes = ["word_cloud"]
  }
  $.each(dataTypes, function(i, dataType) {
    $("#dashboardModalShownDiv #display_type option[data-type='" + dataType + "']").show();
    $("#dashboardModalShownDiv #display_type option[data-type='" + dataType + "']").attr("data-display", "visible");
  });
}

function addWidgetToDashboard() {
  newId = new Date().getTime();
  idText = "#dashboard_dashboard_elements_attributes_replaceId_";
  $("#dashboardElementsList").append("<li style='display: none'></li>");
  var li = $("#dashboardElementsList li:last");
  li.html($("#dashboardElementBlank").html());
  li.find(idText + "survey_element_id").first().val($("#dashboardModalShownDiv #survey_element_id option:selected").val());
  li.find(idText + "display_type").first().val($("#dashboardModalShownDiv #display_type option:selected").val());
  li.append($("#dashboardModalShownDiv #survey_element_id option:selected").text());
  li.append(" - ");
  li.append($("#dashboardModalShownDiv #display_type option:selected").text());
  li.html(li.html().replace(/replaceId/g, newId));
  li.show();
  $.modal.close();
};
