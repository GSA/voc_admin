$(document).ready(function() {
  $("#newWidgetLink").click(function(event) {
    event.preventDefault();
    $("#dashboardModalDiv").modal({
      escClose: true,
      modal: true,
      onClose: function() {
        $.modal.close();
        $("#dashboardModalDiv").hide();
      }
    });

    reporterType = $("#dashboardModalDiv #survey_element_id option:first").data("type");
    $('#dashboardModalDiv').show();
    removeDisplayTypes();
    addDisplayTypes(reporterType);
  });

  $(document).delegate('#dashboardModalDiv #survey_element_id', 'change', function() {
    removeDisplayTypes();
    dataType = $('#dashboardModalDiv #survey_element_id').find("option:selected").data("type")
    addDisplayTypes(dataType);
  });

  $('form .remove_element').click(function(event) {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('li').hide();
    event.preventDefault();
  });

  $(document).delegate('form .remove_pending_element', 'click', function(event) {
    $(this).closest('li').remove();
    event.preventDefault();
  });

  $('#dashboardElementsList').sortable();
  $('.datepicker').datepicker();
});

function removeDisplayTypes() {
  $("#display_type option").remove();
}

function addDisplayTypes(reporterType) {
  var dataTypes = [];
  switch (reporterType) {
    case "choice-multiple":
      dataTypes = ["bar", "line"]
      break;
    case "choice-single":
      dataTypes = ["bar", "pie", "line"]
      break;
    case "text":
      dataTypes = ["word_cloud"]
  }
  $.each(dataTypes, function(i, dataType) {
    $("#display_type").append($("#display_type_with_options option[data-type='" + dataType + "']").clone());
  });
  $("#display_type").val($("#display_type option").first().val());
}

function addWidgetToDashboard() {
  newId = new Date().getTime();
  idText = "#dashboard_dashboard_elements_attributes_replaceId_";
  $("#dashboardElementsList").append("<li style='display: none'></li>");
  var li = $("#dashboardElementsList li:last");
  li.html($("#dashboardElementBlank").html());
  li.find(idText + "survey_element_id").first().val($("#dashboardModalDiv #survey_element_id option:selected").val());
  li.find(idText + "display_type").first().val($("#dashboardModalDiv #display_type option:selected").val());
  li.append($("#dashboardModalDiv #survey_element_id option:selected").text());
  li.append(" - ");
  li.append($("#dashboardModalDiv #display_type option:selected").text());
  li.html(li.html().replace(/replaceId/g, newId));
  li.show();
  $.modal.close();
};
