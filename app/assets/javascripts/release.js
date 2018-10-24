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
});
