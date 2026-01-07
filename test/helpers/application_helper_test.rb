require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  context "hunan_datetime" do
    should "handle date objects" do
      assert_equal "2:27pm on 29 Jan 2025", human_datetime(Time.zone.parse("2025-01-29T14:27:01Z"))
    end

    should "handle date strings" do
      assert_equal "2:27pm on 29 Jan 2025", human_datetime("2025-01-29T14:27:01Z")
    end

    should "handle invalid date strings" do
      assert_equal "", human_datetime("error date")
    end
  end
end
