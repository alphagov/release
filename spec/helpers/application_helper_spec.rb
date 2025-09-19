RSpec.describe ApplicationHelper, type: :helper do
  describe "#human_datetime" do
    it "handles Time objects" do
      result = helper.human_datetime(Time.zone.parse("2025-01-29T14:27:01Z"))

      expect(result).to eq("2:27pm on 29 Jan")
    end

    it "handles date strings" do
      result = helper.human_datetime("2025-01-29T14:27:01Z")

      expect(result).to eq("2:27pm on 29 Jan")
    end

    it "handles invalid date strings" do
      result = helper.human_datetime("error date")

      expect(result).to eq("")
    end

    it "uses the word today if the release was today" do
      time = Time.zone.now.change(hour: 10, min: 2)

      expect(human_datetime(time)).to eq("10:02am today")
    end

    it "uses the word yesterday if the release was yesterday" do
      time = Time.zone.now.change(hour: 10, min: 2) - 1.day

      expect(human_datetime(time)).to eq("10:02am yesterday")
    end

    it "uses the day of the week for current week" do
      Timecop.freeze(Time.zone.parse("2014-07-04 12:44")) do
        time = Time.zone.parse("2014-06-30 10:02")

        expect(human_datetime(time)).to eq("10:02am on Monday")
      end
    end

    it "displays the date for last Sunday" do
      Timecop.freeze(Time.zone.parse("2014-07-04 12:44")) do
        time = Time.zone.parse("2014-06-29 10:02")

        expect(human_datetime(time)).to eq("10:02am on 29 Jun")
      end
    end
  end
end
