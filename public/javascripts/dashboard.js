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
});

function addWidgetToDashboard() {
  $("#dashboardElementsList").append("<li style='display: none'></li>");
  var li = $("#dashboardElementsList li:last");
  li.html($("#dashboardElementBlank").html());
  li.find("#survey_element_id").first().val($("#dashboardModalShownDiv #survey_element_id option:selected").val());
  li.find("#element_type").first().val($("#dashboardModalShownDiv #element_type option:selected").val());
  li.append($("#dashboardModalShownDiv #survey_element_id option:selected").text());
  li.append(" - ");
  li.append($("#dashboardModalShownDiv #element_type option:selected").text());
  li.show();
  $.modal.close();
};
