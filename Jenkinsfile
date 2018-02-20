#!/usr/bin/env groovy

REPOSITORY = 'release'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  govuk.buildProject(sassLint: false, newStyleDockerTags: true)
}
