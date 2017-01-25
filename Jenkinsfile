#!/usr/bin/env groovy

REPOSITORY = 'release'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    buildDiscarder(
      logRotator(
        numToKeepStr: '50')
      ),
    [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
    [$class: 'ThrottleJobProperty',
      categories: [],
      limitOneJobWithMatchingParams: true,
      maxConcurrentPerNode: 1,
      maxConcurrentTotal: 0,
      paramsToUseForLimit: 'release',
      throttleEnabled: true,
      throttleOption: 'category'
    ],
  ])

  try {
    stage("Checkout") {
      checkout scm
    }

    stage("Clean up workspace") {
      govuk.cleanupGit()
    }

    stage("git merge") {
      govuk.mergeMasterBranch()
    }

    stage("Configure Rails environment") {
      govuk.setEnvar("RAILS_ENV", "test")
    }

    stage("bundle install") {
      govuk.bundleApp()
    }

    stage("rubylinter") {
      govuk.rubyLinter("app test lib")
    }

    stage("Precompile assets") {
      govuk.precompileAssets()
    }

    stage("Run tests") {
      govuk.runRakeTask("ci:setup:rspec default")
    }

    stage("Push release tag") {
      govuk.pushTag(REPOSITORY, env.BRANCH_NAME, "release_${env.BUILD_NUMBER}")
    }

    stage("Deploy to integration") {
      govuk.deployIntegration(REPOSITORY, env.BRANCH_NAME, 'release', 'deploy')
    }

  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
