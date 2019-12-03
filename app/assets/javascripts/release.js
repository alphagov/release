$(function () {
  var applicationsFilterInput = $("input[name='applications-filter']")
  var applicationsFilterRows = $("[data-filter-applications]").find(".govuk-table__body .govuk-table__row")

  applicationsFilterInput.on('keyup', function(e) {
    var searchTerm = e.target.value

    applicationsFilterRows.not(function() {
      var currentApplication = $(this)
      var currentApplicationLink = currentApplication.find("[data-filter-applications-link]")
      var currentApplicationText = currentApplicationLink.text()

      currentApplication.removeClass('js-hidden')

      if (currentApplicationText.toLowerCase().includes(searchTerm)) {
        return true
      }
    }).addClass('js-hidden');
  })
});
