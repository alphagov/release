#!/usr/bin/env groovy

library("govuk")

REPOSITORY = 'release'

node {
  govuk.buildProject(
    beforeTest: { sh("yarn install") },
    sassLint: false,
  )
}
