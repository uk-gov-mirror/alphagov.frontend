require "test_helper"

class ElectoralControllerTest < ActionController::TestCase
  include ElectionHelpers

  setup do
    stub_content_store_has_item("/contact-electoral-registration-office")
  end

  context "without postcode params" do
    should "GET show renders show page with form" do
      get :show
      assert_response :success
      assert_template "local_transaction/search"
      assert_template partial: "electoral/_form"
      assert_template partial: "application/_location_form", count: 0
    end
  end

  context "with postcode params" do
    context "that map to a single address" do
      should "GET show renders results page" do
        elections_api_stub = stub_api_postcode_lookup("{}", "LS11UR")

        with_electoral_api_url do
          get :show, params: { postcode: "LS1 1UR" }
          assert_response :success
          assert_template :results
          assert_requested(elections_api_stub)
        end
      end
    end

    context "that maps to multiple addresses" do
      should "GET show renders the address picker template" do
        response = "{\"address_picker\":true,\"addresses\":[]}"
        stub_api_postcode_lookup(response, "IP224DN")

        with_electoral_api_url do
          get :show, params: { postcode: "IP224DN" }
          assert_response :success
          assert_template :address_picker
        end
      end
    end
  end

  context "with uprn params" do
    should "GET show renders results page" do
      elections_api_stub = stub_api_address_lookup("{}", "1234")

      with_electoral_api_url do
        get :show, params: { uprn: "1234" }
        assert_response :success
        assert_template :results
        assert_requested(elections_api_stub)
      end
    end
  end
end
