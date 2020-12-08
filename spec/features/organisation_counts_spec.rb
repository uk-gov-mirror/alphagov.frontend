RSpec.feature "Organisational counts are displayed on the homepage", :type => :feature do
  let(:organisations) do
    {
      "details": {
        "ordered_ministerial_departments": "23",
        "ordered_agencies_and_other_public_bodies": "413"
      }
    }.to_json
  end

  before(:each) do
    stub_request(:get, "http://content-store.dev.gov.uk/content/government/organisations")
      .with(headers: {'Accept'=>'application/json'})
      .to_return(status: 200, body: organisations)

      stub_content_store_has_item("/", schema: "special_route")
    end

  scenario do
    and_given_i_am_on_the_homepage
    i_see_a_count_of_ministerial_departments
    i_see_a_count_of_agenices_or_other_public_bodies
  end

  def and_given_i_am_on_the_homepage
    visit "/"
  end

  def i_see_a_count_of_ministerial_departments
  end

  def i_see_a_count_of_agenices_or_other_public_bodies
  end
end
