require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  context 'validation' do
    should 'be valid without a status_note' do
      assert FactoryGirl.build(:site, status_notes: nil).valid?
    end

    should 'be invalid with a status_note that is longer than 255 chars' do
      assert FactoryGirl.build(:site, status_notes: 'a' * 254).valid?
      assert FactoryGirl.build(:site, status_notes: 'a' * 255).valid?
      refute FactoryGirl.build(:site, status_notes: 'a' * 256).valid?
    end

    should 'be blocked from creating if there is already a site instance' do
      original = FactoryGirl.create(:site, status_notes: 'First!')
      assert original.persisted?

      remake = FactoryGirl.build(:site, status_notes: 'Aw :(')
      refute remake.valid?
      refute remake.save
      assert_equal ['There can only be one Site instance'], remake.errors[:base]
    end
  end
end
