$(function () {
  $('#application-list').tablesorter();

  $("textarea#application_status_notes").autoGrow();

  $('#datetimepicker1').datetimepicker({
    language: 'en'
  });
});