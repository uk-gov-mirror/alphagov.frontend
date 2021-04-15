require "test_helper"

class ElectoralPresenterTest < ActiveSupport::TestCase
  def api_response
    path = Rails.root.join("test/fixtures/electoral-result.json")
    fixture = File.read(path)
    JSON.parse(fixture)
  end

  def electoral_presenter(payload)
    ElectoralPresenter.new(payload)
  end

  context "exposing attributes from the json payload" do
    ElectoralPresenter::EXPECTED_KEYS.each do |exposed_attribute|
      should "expose value of #{exposed_attribute} from payload via a method" do
        subject = electoral_presenter(api_response)
        assert subject.respond_to? exposed_attribute
        assert_equal api_response[exposed_attribute], subject.send(exposed_attribute)
      end
    end
  end

  context "when dates and ballots are present in the api response" do
    should "should present upcoming elections" do
      subject = electoral_presenter(api_response)
      expected = ["2017-05-04 - Cardiff local election Pontprennau/Old St. Mellons"]
      assert_equal subject.upcoming_elections, expected
    end
  end

  context "when a postcode maps to multiple addresses" do
    should "should present addresses" do
      with_multiple_addresses = api_response
      with_multiple_addresses["address_picker"] = true
      with_multiple_addresses["addresses"] = [
        {
          "address" => "1 BUCKINGHAM PALACE",
          "postcode" => "IP22 4DN",
          "slug" => "1234",
          "url" => "/foo",
        },
      ]
      subject = electoral_presenter(with_multiple_addresses)
      expected = ["<a href='/find-electoral-things?uprn=1234'>1 BUCKINGHAM PALACE</a>"]
      assert_equal subject.present_addresses, expected
    end
  end

  context "presenting addresses" do
    context "when duplicate contact details are provided" do
      should "we should not show the electoral services address" do
        with_duplicate_contact = api_response
        with_duplicate_contact["registration"] = { "address" => "foo bar" }
        with_duplicate_contact["electoral_services"] = { "address" => " foo  bar " }
        subject = electoral_presenter(with_duplicate_contact)
        assert_equal subject.use_electoral_services_contact_details?, false
      end
    end

    context "when both contact details are different" do
      should "we should show both addresses" do
        with_different_contact = api_response
        with_different_contact["registration"] = { "address" => "foo bar" }
        with_different_contact["electoral_services"] = { "address" => " baz boo " }
        subject = electoral_presenter(with_different_contact)
        assert_equal subject.use_electoral_services_contact_details?, true
        assert_equal subject.use_registration_contact_details?, true
      end
    end
  end
end
