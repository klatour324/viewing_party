require "rails_helper"
RSpec.describe 'MovieService' do
  describe "#get_data(url)" do
    it "can return JSON from an API endpoint" do
      movie_service_data = MovieService.new
      url = ENV['API_TEST_COUNT_URL']

      expect(movie_service_data.get_data(url).count).to eq(4)
      expect(movie_service_data.get_data(url).keys).to eq([:page, :results, :total_pages, :total_results])
      expect(movie_service_data.get_data(url).class).to eq(Hash)
    end
  end
  describe "#top_forty_movies" do
    it "returns the top 40 movie title/tmdb_ids" do
      VCR.use_cassette('top_forty_movies') do
        movie_service_data = MovieService.new
        results = movie_service_data.top_forty_movies

        expect(results.first[0]).to eq("Gabriel's Inferno Part II")
        expect(results.first[1]).to eq([724089, 8.7])
        expect(results.count).to eq(40)
      end
    end
  end
  describe "#movie_search" do
    it "returns 40 movie title/tmdb_ids that match a search query" do
      VCR.use_cassette('movie_search') do
        movie_service = MovieService.new
        # movie_service_data.movie_search
        search_results = movie_service.movie_search("phoenix")
        expect(search_results.count).to eq(34)
        expect(search_results.first.class).to eq(Array)
        expect(search_results.first).to eq( ["Dark Phoenix", [320288, 6.1]])
        expect(search_results.class).to eq(Hash)
      end
    end
  end
  describe "#results_page_count" do
    it "returns an integer from JSON data regarding number of pages of results" do
        movie_service = MovieService.new
        # Where are you setting this env var locally?
        url = ENV['API_TEST_COUNT_URL']

        expect(movie_service.results_page_count(url)).to eq(500)
    end
  end
  describe "#movie_information" do
    it "returns a hash of movie_information" do
      VCR.use_cassette('movie_info') do
        movie_service = MovieService.new
        movie_info = movie_service.movie_information(550)
        expect(movie_info.class).to eq(Hash)
        expect(movie_info.keys).to eq([:api_id, :title, :vote_average, :runtime, :genres, :summary, :cast, :reviews, :poster_path])
        expect(movie_info[:title]).to eq("Fight Club")
        expect(movie_info[:vote_average]).to eq(8.4)
        expect(movie_info[:runtime]).to eq(139)
        expect(movie_info[:genres]).to eq(["Drama"])
        expect(movie_info[:summary]).to eq( "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.")
        expect(movie_info[:cast].count).to eq(10)
        expect(movie_info[:cast].class).to eq(Hash)
      end
    end
  end
  describe "#movie_info_cast" do
    it "returns an the actor and role they played in the movie" do
      VCR.use_cassette('movie_cast') do
        movie_service = MovieService.new
        movie_cast_info = movie_service.movie_info_cast(550)
        expect(movie_cast_info.keys.first).to eq("Edward Norton")
        expect(movie_cast_info.keys[-1]).to eq("David Andrews")
        expect(movie_cast_info.count).to eq(10)
      end
    end
  end
  describe "#movie_info_reviews" do
    it "should return a hash with the review count and review and authors when there are more than 1 pages of reviews" do
      VCR.use_cassette('movie_reivews') do
        movie_service = MovieService.new
        movie_review_info = movie_service.movie_info_reviews(558)
        expect(movie_review_info.count).to eq(31)
      end
    end
    it "should return a hash with the review count and review and authors when there is only 1 page of reviews" do
      VCR.use_cassette('movie_reivews_550') do
        movie_service = MovieService.new
        movie_review_info = movie_service.movie_info_reviews(550)
        expect(movie_review_info.count).to eq(5)
      end
    end
  end
end
