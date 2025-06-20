require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  context "hunan_datetime" do
    should "can handle date strings" do
      assert_equal "2:27pm on 29 Jan", human_datetime("2025-01-29T14:27:01Z")
    end

    should "can handle invalid date strings" do
      assert_equal "", human_datetime("error date")
    end
  end
end
