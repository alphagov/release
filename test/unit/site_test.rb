require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  context 'validation' do
    should 'be valid without a status_note' do
      assert FactoryBot.build(:site, status_notes: nil).valid?
    end

    should 'be invalid with a status_note that is longer than 255 chars' do
      assert FactoryBot.build(:site, status_notes: 'a' * 254).valid?
      assert FactoryBot.build(:site, status_notes: 'a' * 255).valid?
      assert_not FactoryBot.build(:site, status_notes: 'a' * 256).valid?
    end

    should 'be blocked from creating if there is already a site instance' do
      original = FactoryBot.create(:site, status_notes: 'First!')
      assert original.persisted?

      remake = FactoryBot.build(:site, status_notes: 'Aw :(')
      assert_not remake.valid?
      assert_not remake.save
      assert_equal ['There can only be one Site instance'], remake.errors[:base]
    end
  end

  context '.settings' do
    should "return an unsaved instance if no instance is persisted already" do
      assert_not Site.settings.persisted?
    end

    should "return an the persisted instance if one has be saved already" do
      site = FactoryBot.create(:site)
      assert Site.settings.persisted?
      assert_equal site, Site.settings
    end
  end
end
