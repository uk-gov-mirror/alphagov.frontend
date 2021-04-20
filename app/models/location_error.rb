class LocationError
  MESSAGES = {
    "fullPostcodeNoMapitMatch" => "formats.local_transaction.valid_postcode_no_match",
    "noLaMatch" => "formats.local_transaction.no_local_authority",
    "validPostcodeNoLocation" => "formats.find_my_nearest.valid_postcode_no_locations",
    "invalidPostcodeFormat" => "formats.local_transaction.invalid_postcode",
    "invalidUprnFormat" => "formats.local_transaction.invalid_uprn",
  }.freeze

  SUB_MESSAGES = {
    "fullPostcodeNoMapitMatch" => "formats.local_transaction.valid_postcode_no_match_sub_html",
    "invalidPostcodeFormat" => "formats.local_transaction.invalid_postcode_sub",
    "invalidUprnFormat" => "formats.local_transaction.invalid_uprn_sub",
  }.freeze

  attr_reader :postcode_error, :message, :sub_message, :message_args

  def initialize(postcode_error = nil, message_args = {})
    @postcode_error = postcode_error
    @message_args = message_args

    if MESSAGES[postcode_error]
      @message = MESSAGES[postcode_error]
      @sub_message = SUB_MESSAGES.fetch(postcode_error, "")
    else
      @message = "formats.local_transaction.invalid_postcode"
      @sub_message = "formats.local_transaction.invalid_postcode_sub"
    end
  end
end
