require 'spec_helper'

describe "Application management" do
  describe "showing application information" do
    let(:application_1) { Application.new(name: "beavis", repo: "beavis.com") }
    let(:application_2) { Application.new(name: "butthead", repo: "butthead.com") }

    before do
      application_1.save
      application_2.save

      visit "/applications"
    end

    it "should have an OK response code" do
      page.status_code.should eq(200)
    end

    it "should show the applications we have in our database" do
      page.body.should include(application_1.name, application_2.name)
    end

    it "should have links to the applications" do
      page.should have_link(application_1.name)
      page.should have_link(application_2.name)
    end
  end

  describe "creating applications" do
    before do
      visit "/applications"
      click_on "Create Application"
    end

    describe "error cases" do
      it "should error when the form is submitted with empty fields" do
        click_on "Create Application"
        page.should have_content("There are some problems with the application")
      end

      it "should validate the model upon submission" do
        Application.any_instance.should_receive(:valid?).once
        click_on "Create Application"
      end

      describe "duplicating exisiting applications" do
        let(:existing) { Application.new(name: "An existing app", repo: "thisexists.com") }

        before do
          existing.save
        end

        it "should error when fields are filled with details of an existing application" do
          fill_in :application_name, with: existing.name
          fill_in :application_repo, with: existing.repo

          click_on "Create Application"

          page.should have_content("There are some problems with the application")
        end
      end

      it "should error if only the 'name' field is filled out" do
        fill_in :application_name, with: "some name that doesn't exist yet"

        click_on "Create Application"

        page.should have_content("There are some problems with the application")
      end

      it "should error if only the 'repo' field is filled out" do
        fill_in :application_repo, with: "somerepothatdoesntexistyet.com"

        click_on "Create Application"

        page.should have_content("There are some problems with the application")
      end
    end

    describe "saving a valid Application record" do
      it "should validate and save the submission" do
        Application.any_instance.should_receive(:valid?).once.and_return(true)
        Application.any_instance.should_receive(:save).once.and_return(true)

        fill_in :application_name, with: "chess master"
        fill_in :application_repo, with: "chessmaster.com"

        click_on "Create Application"
      end

      it "should show a success message to the user" do
        fill_in :application_name, with: "zen master"
        fill_in :application_repo, with: "zenmaster.com"

        click_on "Create Application"

        page.should have_content("Successfully created new application")
      end
    end
  end
end
