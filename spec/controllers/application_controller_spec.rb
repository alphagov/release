require 'spec_helper'

describe ApplicationController do
  describe "behaviour for all subclasses" do
    controller do
      def index
        render :text => "Jabberwocky"
      end
    end

    describe "caching" do
      before do
        get :index
      end

      it "should have a max-age of 5 minutes" do
        response.headers["Cache-Control"].should include "max-age=300"
      end

      it "should have a public directive" do
        response.headers["Cache-Control"].should include "public"
      end
    end
  end
end
