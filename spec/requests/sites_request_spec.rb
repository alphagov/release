RSpec.describe "Sites", type: :request do
  before do
    login_as_stub_user
  end

  describe "GET /site" do
    it "renders the show template with an empty form when no site settings are persisted" do
      get site_path

      expect(response).to render_template(:show)
      expect(response).to have_http_status(:ok)

      expect(response.body).to have_css("form[action='/site']")
      expect(response.body).to have_css(".govuk-textarea[name='site[status_notes]']",
                                        text: "")
    end

    it "renders the show template with existing site settings in the form when site settings exist" do
      FactoryBot.create(:site, status_notes: "Deploy freeze in place.")

      get site_path

      expect(response.body).to have_css("form[action='/site']")
      expect(response.body).to have_css(".govuk-textarea[name='site[status_notes]']",
                                        text: "Deploy freeze in place.")
    end
  end

  describe "PATCH /site" do
    it "creates site settings when no settings exist" do
      expect(Site.settings).not_to be_persisted

      patch site_path, params: { site: { status_notes: "Deploy freeze in place." } }

      expect(response).to redirect_to(root_path)
      expect(Site.settings).to be_persisted
      expect(Site.settings.status_notes).to eq("Deploy freeze in place.")
    end

    it "updates the existing site settings when settings already exist" do
      site_settings = FactoryBot.create(:site, status_notes: "Deploys are frozen for now.")

      patch site_path, params: { site: { status_notes: "Deploy freeze in place." } }

      expect(response).to redirect_to(root_path)
      expect(site_settings.reload.status_notes).to eq("Deploy freeze in place.")
    end

    it "responds with unprocessable entity for invalid input" do
      patch site_path, params: { site: { status_notes: SecureRandom.alphanumeric(1000) } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
