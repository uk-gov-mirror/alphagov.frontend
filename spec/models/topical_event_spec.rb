RSpec.describe TopicalEvent do
  include GdsApi::TestHelpers::Search

  subject(:topical_event) { described_class.new(content_store_response) }

  let(:content_store_response) { GovukSchemas::Example.find("topical_event", example_name: "western-balkans-summit-london-2018") }

  let(:search_results) do
    {
      results: [
        {
          link: "/news/my-item",
          title: "My Topical Event News Item",
          public_timestamp: "2025-12-01T00:00:01Z",
          display_type: "news",
          description: "What's up?",
        },
      ],
    }
  end

  before { stub_any_search.to_return(body: search_results.to_json) }

  describe "who's involved initialisation" do
    it "creates an Involved with appropriate settings" do
      expect(FlexiblePage::FlexibleSection::Involved).to receive(:new) do |settings, _|
        expect(settings[:organisations].first).to be_a(Organisation)
        expect(settings[:organisations].first.title).to eq(content_store_response["links"]["organisations"][0]["title"])
      end

      topical_event
    end

    context "when there are no organisations" do
      let(:content_store_response) do
        GovukSchemas::Example.find("topical_event", example_name: "western-balkans-summit-london-2018").tap do |item|
          item["links"]["organisations"] = nil
        end
      end

      it "doesn't create an Involved" do
        expect(FlexiblePage::FlexibleSection::Involved).not_to receive(:new)

        topical_event
      end
    end
  end

  describe "#header_image" do
    let(:content_store_response) { GovukSchemas::Example.find("topical_event", example_name:) }
    let(:example_name) { "topical-event" }

    it "returns the first image of type header" do
      expect(topical_event.header_image[:type]).to eq("header")
    end

    context "when rendering a legacy topical event" do
      let(:example_name) { "western-balkans-summit-london-2018" }

      it "returns nil" do
        expect(topical_event.header_image).to be_nil
      end
    end
  end

  describe "#logo_image" do
    let(:content_store_response) { GovukSchemas::Example.find("topical_event", example_name:) }
    let(:example_name) { "topical-event" }

    it "returns the first image of type logo" do
      expect(topical_event.logo_image[:type]).to eq("logo")
    end

    context "when rendering a legacy topical event" do
      let(:example_name) { "western-balkans-summit-london-2018" }

      it "returns nil" do
        expect(topical_event.logo_image).to be_nil
      end
    end
  end

  describe "#legacy_logo" do
    let(:content_store_response) { GovukSchemas::Example.find("topical_event", example_name:) }
    let(:example_name) { "topical-event" }

    it "returns nil" do
      expect(topical_event.legacy_logo).to be_nil
    end

    context "when rendering a legacy topical event" do
      let(:example_name) { "western-balkans-summit-london-2018" }

      it "returns the legacy logo suitable for use as a header image" do
        expect(topical_event.legacy_logo.key?(:type)).to be false
        expect(topical_event.legacy_logo[:sources]).not_to be_nil
      end
    end
  end
end
