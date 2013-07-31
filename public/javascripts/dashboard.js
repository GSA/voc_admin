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

  $('form .remove_element').click(function() {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('li').hide();
  });

  $('form .remove_pending_element').live('click', function() {
    $(this).closest('li').remove();
  });

  $('#dashboardElementsList').sortable();
});

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
