require "spec_helper"

describe "Deployment task management" do
  let(:application1) { Application.new(name: "beavis", repo: "beavis.com") }
  let(:application2) { Application.new(name: "butthead", repo: "butthead.com") }

  before(:each) do
    login_as_warden_user

    application1.save
    application2.save
  end

  describe "showing deployment task information" do
    let(:task1) { application1.tasks.create(version: "release_1") }
    let(:task2) { application2.tasks.create(version: "release_2") }

    before do
      task1.save
      task2.save

      visit "/tasks"
    end

    it "should have an OK response code" do
      page.status_code.should == 200
    end

    it "should show all tasks" do
      page.body.should include(task1.version, task2.version)
    end

    it "should have links to the applications" do
      page.should have_link(application1.name)
      page.should have_link(application2.name)
    end

    it "should display tasks in reverse chronological order" do
      rows = page.all(:css, "table tbody tr")
      rows[0].should have_link(application1.name)
      rows[1].should have_link(application2.name)
    end
  end

  describe "creating deployment tasks" do
    before do
      visit "/tasks"
      click_on "Create Deploy Task"
    end

    it "should show a select box of applications" do
      within("select") do
        page.should have_content(application1.name)
        page.should have_content(application2.name)
      end
    end

    describe "error cases" do
      it "should fail if no application is selected" do
        fill_in :task_version, with: "New task"
        fill_in :task_description, with: "New description"
        click_on "Create Task"
        page.should have_content("There are some problems with the deploy task")
      end

      it "should fail if no version is entered" do
        select application1.name, from: "Application"
        fill_in :task_description, with: "New description"
        click_on "Create Task"
        page.should have_content("There are some problems with the deploy task")
      end

      it "should fail if no application or version is entered" do
        fill_in :task_description, with: "New description"
        click_on "Create Task"
        page.should have_content("There are some problems with the deploy task")
      end
    end

    describe "saving a valid deployment task record" do
      before do
        select application1.name, from: "Application"
        fill_in :task_version, with: "release_22"
        fill_in :task_description, with: "New description"
        click_on "Create Task"
      end
      it "should show a success message" do
        page.should have_content("Successfully created new deploy task")

      end
      it "should appear in the list page" do
        visit "/tasks"
        within("table tbody") do
          page.should have_content("release_22")
        end
      end
    end
  end
end
