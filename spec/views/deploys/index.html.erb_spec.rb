require 'spec_helper'

describe "deploys/index.html.erb" do
  let(:slicer) { Application.new(name: "slicer") }
  let(:dicer) { Application.new(name: "dicer") }
  let(:three_days) { 3.days.from_now }
  let(:four_days) { 4.days.from_now }

  before do
    slicer.save
    dicer.save

    assign(:deploys, [
      stub_model(Deploy, application: slicer, version: "release_101", created_at: three_days),
      stub_model(Deploy, application: dicer, version: "build-3522", created_at: four_days)
    ])

    render
  end

  it "should display links to the parent applications" do
    rendered.should have_link(slicer.name, href: url_for(slicer))
    rendered.should have_link(dicer.name, href: url_for(dicer))
  end

  it "should display the created at date" do
    rendered.should have_content(three_days)
    rendered.should have_content(four_days)
  end

  it "should have the deploy versions" do
    rendered.should have_content("release_101")
    rendered.should have_content("build-3522")
  end
end
