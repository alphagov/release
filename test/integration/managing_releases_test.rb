require 'integration_test_helper'

class ManagingReleasesTest < JavascriptIntegrationTest

  setup do
    login_as_stub_user
  end

  context "all releases" do
    should "show today's releases" do
      todays_releases = FactoryGirl.create_list(:release, 5, :deploy_at => Date.today.change(:hour => 12))

      visit '/releases'

      within_table('today') do
        todays_releases.each do |release|
          assert page.has_link?("##{release.id}", :href => "/releases/#{release.id}")
          assert page.has_content?(release.applications.map(&:name).join(', '))
        end
      end
    end

    should "show future releases" do
      future_releases = FactoryGirl.create_list(:release, 5, :deploy_at => Date.today.tomorrow.change(:hour => 12))

      visit '/releases'

      within_table('future') do
        future_releases.each do |release|
          assert page.has_link?("##{release.id}", :href => "/releases/#{release.id}")
          assert page.has_content?(release.applications.map(&:name).join(', '))
        end
      end
    end
  end

  context "a single release" do
    setup do
      @release = FactoryGirl.create(:release)
    end

    should "show basic information about the release" do
      visit "/releases/#{@release.id}"

      assert page.has_content?("Release #{@release.id}")

      within "dl" do
        assert page.has_content?(@release.notes)
      end
    end

    should "list associated tasks" do
      visit "/releases/#{@release.id}"

      within_table "tasks" do
        @release.tasks.each do |task|
          assert page.has_content?(task.description.to_s)
          assert page.has_content?("#{task.version}")
          assert page.has_link?(task.application.name, :href => "/applications/#{task.application.friendly_id}")
        end
      end
    end
  end

  context "booking a release" do
    setup do
      @application_one = FactoryGirl.create(:application, name: "Smart Answers")
      @application_two = FactoryGirl.create(:application, name: "Migratorator")
    end

    should "create a release given valid attributes" do
      visit '/releases'
      click_on 'Book a release'

      fill_in "Summary", :with => "Deploy a new smart answer, changes to an existing smart answer and bug fixes for Migratorator"
      fill_in "Additional notes", :with => "This release must take place today to prepare for the introduction of new tax rules tomorrow."
      fill_in "Product team members", :with => "Winston Smith-Churchill\nHiro Protagonist\nBug Barbecue"
      fill_in "Additional support notes", :with => "We may expect an increased number of support requests from users due to the smart answer amends"

      fill_in "Deploy at", :with => Time.zone.now.strftime('%d/%m/%Y %H:%M')

      click_link "Add a task"

      within(".tasks-group fieldset") do
        select "Smart Answers", :from => "Application"
        fill_in "Version", :with => "release_123"
        fill_in "Description", :with => "Deploy Child Benefit Tax Calculator"
      end

      click_on "Create Release"

      save_page

      assert page.has_content?('created new release')

      assert page.has_content?('Deploy a new smart answer')
      assert page.has_content?('This release must take place today')
      assert page.has_content?("Winston Smith-Churchill")
      assert page.has_content?("We may expect an increased number of support requests")
      assert page.has_content?("Stub User")

      within_table 'tasks' do
        assert page.has_content?('Smart Answers')
        assert page.has_content?('release_123')
        assert page.has_content?('Deploy Child Benefit Tax Calculator')
      end
    end
  end

end
