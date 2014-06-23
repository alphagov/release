require 'rails_helper'

describe User do

  describe "#may_deploy?" do
    subject {User.new}
    context "when the user has deploy permissions" do
      let(:user_permissions) {["signin", "deploy"]}
      before do
        subject.stub(:permissions).and_return user_permissions
      end
      it "returns true when may_deploy? called" do 
        subject.may_deploy?.should == true
      end
    end
    context "when the user has deploy permissions" do
      let(:user_permissions) {["signin"]}
      before do
        subject.stub(:permissions).and_return user_permissions
      end
      it "returns false when may_deploy? called" do 
        subject.may_deploy?.should == false 
      end
    end
     
  end

end
