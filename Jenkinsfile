#!/usr/bin/env groovy

REPOSITORY = 'release'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  govuk.buildProject(overrideTestTask: {
    stage("Run tests") {
      govuk.runRakeTask("ci:setup:rspec default")
    }
  }, sassLint: false, newStyleDockerTags: true)
}
