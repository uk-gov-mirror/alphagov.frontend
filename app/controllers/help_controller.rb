class HelpController < ApplicationController
  include Cacheable

  def index
    setup_content_item("/help")
  end

  def tour
    setup_content_item("/tour")
    render locals: { full_width: true }
  end

  def cookie_settings
    # TODO: replace this with the actual path once this has been decided and a content item is published
    setup_content_item("/tour")
  end

  # TODO: remove after user testing
  def cookie_details
    setup_content_item("/tour")
  end

  def universal_credit
    setup_content_item("/tour")
  end

  def ab_testing
    setup_content_item("/help/ab-testing")
    ab_test = GovukAbTesting::AbTest.new("Example", dimension: 40)
    @requested_variant = ab_test.requested_variant(request.headers)
    @requested_variant.configure_response(response)
  end

private

  def slug_param
    params[:slug] || 'help'
  end
end
