require "test_helper"

class UnavailableServiceTest < ActiveSupport::TestCase
  setup do
    UnavailableService.stubs(:load_config).returns(
      YAML.safe_load(File.open(Rails.root.join("test/fixtures/unavailable_services.yml"))),
    )
    @config = UnavailableService.load_config
  end

  context "#initialize" do
    context "converts the LGSL code" do
      should "be an integer when given an integer" do
        unavailable_service = UnavailableService.new(461, "Scotland", @config)
        assert_equal(461, unavailable_service.lgsl)
        assert_kind_of(Integer, unavailable_service.lgsl)
      end

      should "be an integer when given an string" do
        unavailable_service = UnavailableService.new("461", "Scotland", @config)
        assert_equal(461, unavailable_service.lgsl)
        assert_kind_of(Integer, unavailable_service.lgsl)
      end

      should "be an integer when given nil" do
        assert_raises StandardError do
          UnavailableService.new(nil, "Scotland", @config)
        end
      end

      should "be an integer when given an empty string" do
        assert_raises StandardError do
          UnavailableService.new("", "Scotland", @config)
        end
      end
    end

    context "ensures we have a valid config" do
      should "ensure the config is not nil" do
        assert_raises StandardError do
          UnavailableService.new(461, "Scotland", nil)
        end
      end

      should "ensure the config is a hash" do
        UnavailableService.new(461, "Scotland", {})
      end
    end
  end

  context "#unavailable?" do
    should "be available if the service is missing" do
      unavailable_service = UnavailableService.new(1234, "Scotland", @config)
      assert_equal(false, unavailable_service.unavailable?)
    end

    should "be available if country is missing" do
      unavailable_service = UnavailableService.new(461, "Northern Ireland", @config)
      assert_equal(false, unavailable_service.unavailable?)
    end

    should "be unavailable only when the service and country combination is present" do
      unavailable_service = UnavailableService.new(461, "Scotland", @config)
      assert_equal(true, unavailable_service.unavailable?)
    end
  end
end
