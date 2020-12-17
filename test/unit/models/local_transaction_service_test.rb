require "test_helper"

class LocalTransactionServiceTest < ActiveSupport::TestCase
  setup do
    file = File.open(Rails.root.join("test/fixtures/unavailable_services.yml"))
    File.stubs(:open).returns(file)
  end
  
  context ".unavailable?" do
    should "include Scotland for service 461" do
      assert true, LocalTransactionService.unavailable?(461, "Scotland")
    end

    should "not include Northern Ireland for service 461" do
      assert_not LocalTransactionService.unavailable?(461, "Northern Ireland")
    end
  end
end
