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

  var environment = new Bloodhound({
    local: [{value: 'staging'}, {value: 'production'}],
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
  });
  environment.initialize();
  $('.environment-typeahead').typeahead(null, { source: environment.ttAdapter()});

  var version = new Bloodhound({
    local: [{value: 'release_'}, {value: 'build-'}],
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
  });
  version.initialize();
  $('.version-typeahead').typeahead(null, { source: version.ttAdapter()});
});
