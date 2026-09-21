RSpec.describe GonePresenter do
  let(:content_store_response) { GovukSchemas::Example.find("gone", example_name: "gone") }
  let(:content_item) { described_class.new(content_store_response.merge({ "title" => "Something" })).content_item }
  let(:presenter) { described_class.new(content_item.merge({ "title" => "Something" })) }

  describe "#page_title_options" do
    it "has a heading that differs from the content item" do
      expect(content_item["title"]).to eq("Something")
      expect(presenter.page_title_options[:heading_text]).to eq("Something Else")
    end
  end
end
