require 'integration_test_helper'

class ManagingReleasesTest < ActionDispatch::IntegrationTest

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
          assert page.has_content?(task.description)
          assert page.has_content?("v#{task.version}")
          assert page.has_link?(task.application.name, :href => "/applications/#{task.application.id}")
        end
      end
    end
  end

end
