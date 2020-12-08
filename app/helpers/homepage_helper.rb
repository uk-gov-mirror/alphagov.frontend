require 'pry'

module HomepageHelper
  def organisations_path
    Plek.find("content-store") + "/content/government/organisations"
  end

  def organisations_json
    JSON.parse(RestClient.get(organisations_path))
  end

  def ministerial_departments_count
    organisations_json.dig("details", "ordered_ministerial_departments").count
  end

  def other_agencies_public_bodies_count
    organisations_json.dig("details", "ordered_agencies_and_other_public_bodies").count
  end
end
