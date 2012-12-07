require "spec_helper"

describe "Release management" do
  let(:application1) { Application.new(name: "beavis", repo: "beavis.com") }
  let(:application2) { Application.new(name: "butthead", repo: "butthead.com") }

  let(:task1) { application1.tasks.create(version: "release_1") }
  let(:task2) { application2.tasks.create(version: "release_2") }
  let(:task3) { application2.tasks.create(version: "release_3") }

  before(:each) do
    application1.save
    application2.save

    task1.save
    task2.save
    task3.save
  end

  describe "showing release information" do
    let(:release1) { Release.new }
    let(:release2) { Release.new }

    before(:each) do
      release1.tasks << task1
      release1.tasks << task2
      release1.save

      release2.tasks << task3
      release2.save

      visit "/releases"
    end

    it "should have an OK response code" do
      page.status_code.should == 200
    end

    it "should show all releases" do
      page.body.should include(application1.name, application2.name)
    end
  end

  describe "creating releases" do
    before(:each) do
      visit "/releases"
      click_on "Create Release"
    end

    describe "list tasks" do

      it "should display a list of deployment tasks" do
        within("#release_tasks_input") do
          page.should have_content(task1.version)
          page.should have_content(task2.version)
          page.should have_content(task3.version)
        end
      end

      it "should hide deployment tasks already attached to a release" do
        release = Release.new
        release.tasks << task2
        release.save

        visit "/releases"
        click_on "Create Release"

        within("#release_tasks_input") do
          page.should_not have_content(task2.version)
        end
      end
    end

    describe "error cases" do
      it "should fail if no task is selected" do
        click_on "Create Release"

        page.should have_content("There are some problems with the release")
      end

      it "should fail if more than one task for the same application is selected"
    end

    describe "saving a valid release record" do
      before do
        find("#release_task_ids_#{task1.id}").set(true)
        fill_in :release_notes, with: "New description"
        click_on "Create Release"
      end

      it "should show a success message" do
        page.should have_content("Successfully created new release")
      end

      it "should appear in the list page" do
        visit "/releases"
        within("table tbody") do
          page.should have_content(task1.application.name)
          page.should_not have_content(task2.application.name)
        end
      end
    end
  end
end