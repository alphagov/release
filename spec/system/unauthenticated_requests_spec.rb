RSpec.describe "Unauthenticated requests", type: :system do
  it "does not display signed-in user details when user is not authenticated" do
    visit "/auth/failure"

    expect(page).not_to have_content("Signed in as")
  end
end

# # For debugging driver issues
# require "selenium-webdriver"

# driver = Selenium::WebDriver.for :chrome
# driver.get "http://www.google.com"
# puts driver.title
# driver.quit
