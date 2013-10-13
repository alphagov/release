$(function () {
  $.tablesorter.addParser({
    id: 'release-num-and-date',
    is: function (s) {
      return false; // auto detection of this parser off
    },
    format: function (s, table, cell, cellIndex) {
      return $(cell).attr('title');
    },
    type: 'text'
  });

  $('#application-list').tablesorter({
    headers: {
      2: {
        sorter: 'release-num-and-date'
      },
      3: {
        sorter: 'release-num-and-date'
      }
    }
  });

  $("textarea#application_status_notes").autoGrow();

  $('#datetimepicker1').datetimepicker({
    language: 'en'
  });

  $('.environment-typeahead').typeahead({ source: ['staging', 'production'] });

  $('.version-typeahead').typeahead({ source: ['release_', 'build-'] });
});
