require "rails_helper"

RSpec.describe 'MovieService' do
  it "exists" do
    movie_service_data = MovieService.new

    expect(movie_service_data).to be_a(MovieService)
  end

  # it "grabs the next public holidays for the US" do
  #   VCR.use_cassette("nager_data_service_next_public_holidays") do
  #     nagerdate_service_data = NagerDateService.new("US")
  #     public_holidays = nagerdate_service_data.next_public_holidays
  #
  #     expect(public_holidays.count).to eq(3)
  #     expect(public_holidays.first.local_name).to eq("Memorial Day")
  #     expect(public_holidays.first.date).to eq("2021-05-31")
  #     expect(public_holidays[1].local_name).to eq("Independence Day")
  #     expect(public_holidays[1].date).to eq("2021-07-05")
  #     expect(public_holidays.last.local_name).to eq("Labor Day")
  #     expect(public_holidays.last.date).to eq("2021-09-06")
  #   end
  end


end
