require "rails_helper"

RSpec.describe 'MovieService' do
  it 'exists' do
    movie_service_data = MovieService.new

    expect(movie_service_data).to be_a(MovieService)
  end

  it 'gets the top 40 movies by vote average' do
    VCR.use_cassette('tmdb_top_40') do
      movie_service_data = MovieService.new
      top_40_vote_average = movie_service_data.movies_by_vote_average

      expect(top_40_vote_average.length).to eq(40)
    end
  end


end
