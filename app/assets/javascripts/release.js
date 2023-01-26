var ready = function (callback) {
  if (document.readyState !== 'loading') callback()
  else document.addEventListener('DOMContentLoaded', callback)
}

ready(function () {
  var applicationsFilterInput = document.querySelector("input[name='applications-filter']")
  var applicationsFilterRows = document.querySelectorAll('[data-filter-applications] .govuk-table__body > .govuk-table__row')

  if (applicationsFilterInput) {
    applicationsFilterInput.addEventListener('keyup', function (e) {
      var searchTerm = e.target.value.toLowerCase()

      applicationsFilterRows.forEach(function (row) {
        var appName = row.querySelector('[data-filter-applications-link]').textContent

        if (appName.toLowerCase().includes(searchTerm)) {
          row.classList.remove('js-hidden')
        } else {
          row.classList.add('js-hidden')
        }
      })
    })
  }
})
