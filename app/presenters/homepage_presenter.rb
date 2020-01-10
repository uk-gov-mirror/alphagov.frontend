require "gds_api/organisations"

class HomepagePresenter
  def initialize
    @all_organisations ||= all_organisations
  end

  def all_organisations
    organisations_api = GdsApi::Organisations.new(Plek.new.website_root)
    organisations = organisations_api.organisations.with_subsequent_pages.to_a

    @all_organisations = organisations.select {|org| !org["details"]["govuk_status"].eql?("closed") && !org["details"]["govuk_status"].eql?("devolved")}
  end

  def ministerial_department_count
    @all_organisations.select {|org| org["format"].eql?("Ministerial department") }.count
  end

  def other_agencies_count
    @all_organisations.select {|org| org["format"].eql?("Executive non-departmental public body") || org["format"].eql?("Executive agency") || org["format"].eql?("Advisory non-departmental public body") || org["format"].eql?("Other") }.count
  end
end
