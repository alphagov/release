RSpec.describe Site do
  describe "validations" do
    it "is valid without a status_note" do
      expect(FactoryBot.build(:site, status_notes: nil)).to be_valid
    end

    it "is invalid with a status_note longer than 255 characters" do
      expect(FactoryBot.build(:site, status_notes: "a" * 255)).to be_valid
      expect(FactoryBot.build(:site, status_notes: "a" * 256)).not_to be_valid
    end

    it "prevents creation if a Site instance already exists" do
      original = FactoryBot.create(:site, status_notes: "First!")
      expect(original).to be_persisted

      remake = FactoryBot.build(:site, status_notes: "Aw :(")
      expect(remake).not_to be_valid
      expect(remake.save).to be false
      expect(remake.errors[:base]).to include("There can only be one Site instance")
    end
  end

  describe ".settings" do
    it "returns an unsaved instance when no instance is persisted" do
      expect(described_class.settings).not_to be_persisted
    end

    it "returns the persisted instance when a site has been saved" do
      site = FactoryBot.create(:site)
      expect(described_class.settings).to be_persisted
      expect(described_class.settings).to eq(site)
    end
  end
end
