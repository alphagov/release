require "component_test_helper"

class TabsTest < ComponentTestCase
  def component_name
    "tabs"
  end

  test "does not render anything if no data is passed" do
    assert_empty render("components/tabs", {})
  end

  test "renders tabs and sections" do
    render "components/tabs",
           tabs: [
             {
               label: "First section",
               href: "/page1",
             },
             {
               label: "Second section",
               href: "/page2",
             },
           ]

    assert_select ".govuk-tabs"
    assert_select ".govuk-tabs__tab", 2
    assert_select ".govuk-tabs__list-item", 2
    assert_select ".govuk-tabs__tab[href='/page1']"
    assert_select ".govuk-tabs__tab[href='/page2']"
  end
end
