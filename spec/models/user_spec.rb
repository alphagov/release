require 'rails_helper'

describe User do

  describe "#may_deploy?" do
    subject {User.new}
    context "when the user has deploy permissions" do
      let(:user_permissions) {["signin", "deploy"]}
      before do
        allow(subject).to receive(:permissions).and_return user_permissions
      end
      it "returns true when may_deploy? called" do 
        expect(subject.may_deploy?).to be true
      end
    end
    context "when the user has deploy permissions" do
      let(:user_permissions) {["signin"]}
      before do
        allow(subject).to receive(:permissions).and_return user_permissions
      end
      it "returns false when may_deploy? called" do 
        expect(subject.may_deploy?).to be false
      end
    end
     
  end

end
