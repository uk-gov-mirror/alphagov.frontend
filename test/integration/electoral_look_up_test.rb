require "integration_test_helper"

class ElectoralLookUpTest < ActionDispatch::IntegrationTest
  include ElectionHelpers

  TEST_API_URL = "https://test.example.org/api/v1".freeze

  setup do
    content = GovukSchemas::Example.find("local_transaction", example_name: "local_transaction")
    content["title"] = "Contact your local Electoral Registration Office"
    stub_content_store_has_item("/contact-electoral-registration-office", content)
  end

  def search_for(postcode:)
    visit "/find-electoral-things"
    fill_in "postcode", with: postcode
    click_button "Find"
  end

  def api_response
    path = Rails.root.join("test/fixtures/electoral-result.json")
    File.read(path)
  end

  context "visiting the homepage" do
    should "contain a form for entering a postcode" do
      visit "/find-electoral-things"
      assert page.has_selector?("h1", text: "Contact your local Electoral Registration Office", visible: true)
      assert page.has_field?("postcode")
    end
  end

  context "searching by postcode" do
    context "when a valid postcode is entered which matches a single address" do
      should "display upcoming elections if available" do
        with_electoral_api_url do
          stub_api_postcode_lookup("LS11UR", response: api_response)

          search_for(postcode: "LS11UR")
          assert page.has_selector?("h2", text: "Next elections")
          assert page.has_text?("2017-05-04 - Cardiff local election Pontprennau/Old St. Mellons")
        end
      end

      should "display the electoral service (council) address if it's different to the registration office address" do
        with_different_address = JSON.parse(api_response)
        with_different_address["registration"] = { "address" => "foo" }
        with_different_address["electoral_services"] = { "address" => "bar" }
        stub_api_postcode_lookup("LS11UR", response: with_different_address.to_json)

        with_electoral_api_url do
          search_for(postcode: "LS11UR")
          assert page.has_selector?("h2", text: "Your local council")
          assert page.has_text? "For questions about your poll card, polling place, or about returning your postal voting ballot, contact your council."
          assert page.has_selector?("address", text: "foo")

          assert page.has_selector?("h2", text: "Get help with electoral registration")
          assert page.has_text? "Need help? Get in touch with your local electoral registration team."
          assert page.has_selector?("address", text: "bar")
        end
      end

      should "not display the electoral service (council) address if it's the same as the registration office address" do
        duplicate_contact_information = JSON.parse(api_response)
        duplicate_contact_information["registration"] = { "address" => "foo" }
        duplicate_contact_information["electoral_services"] = { "address" => "foo" }
        stub_api_postcode_lookup("LS11UR", response: duplicate_contact_information.to_json)

        with_electoral_api_url do
          search_for(postcode: "LS11UR")

          assert page.has_no_selector?("h2", text: "Your local council")
          assert page.has_no_text?("For questions about your poll card, polling place, or about returning your postal voting ballot, contact your council.")
        end
      end

      should "inform user if there are no upcoming elections " do
        without_dates = JSON.parse(api_response)
        without_dates["dates"] = []
        stub_api_postcode_lookup("LS11UR", response: without_dates.to_json)

        with_electoral_api_url do
          search_for(postcode: "LS11UR")

          assert page.has_selector?("h2", text: "Next elections")
          assert page.has_text?("There are no upcoming elections for your area")
        end
      end
    end

    context "when a valid postcode is entered which matches multiple addresses" do
      should "display an address picker" do
        postcode = "IP224DN"
        with_multiple_addresses = JSON.parse(api_response)
        with_multiple_addresses["address_picker"] = true
        with_multiple_addresses["addresses"] = [
          {
            "address" => "1 BUCKINGHAM PALACE",
            "postcode" => postcode,
            "slug" => "1234",
            "url" => "/foo",
          },
          {
            "address" => "2 BUCKINGHAM PALACE",
            "postcode" => postcode,
            "slug" => "5678",
            "url" => "/bar",
          },
        ]
        # Search for postcode
        stub_api_postcode_lookup(postcode, response: with_multiple_addresses.to_json)

        with_electoral_api_url do
          search_for(postcode: postcode)

          # Multiple addresses are displayed
          assert page.has_selector?("h1", text: "Choose your address")
          assert page.has_selector?("p", text: "The IP22 4DN postcode could be in several council areas. Please choose your address from the list below.")
          assert page.has_link?("1 BUCKINGHAM PALACE", href: "/find-electoral-things?uprn=1234")

          # Click on one of the suggested addresses
          stub_api_address_lookup("1234", response: api_response)
          click_link("1 BUCKINGHAM PALACE")
          assert page.has_selector?("p", text: "We've matched the postcode to Cardiff Council")
        end
      end
    end
  end
end
