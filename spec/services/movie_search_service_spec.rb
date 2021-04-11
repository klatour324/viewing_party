require "rails_helper"
require "ostruct"

RSpec.describe MovieSearchService do
  describe "::get_data(url)" do
    it "can return JSON from an API endpoint" do
      url = ENV['API_TEST_COUNT_URL']

      expect(MovieSearchService.get_data(url).count).to eq(4)
      expect(MovieSearchService.get_data(url).keys).to eq([:page, :results, :total_pages, :total_results])
      expect(MovieSearchService.get_data(url).class).to eq(Hash)
    end
  end
  describe "::top_movies" do
    it "returns the top 40 movie title/tmdb_ids" do
      VCR.use_cassette('top_movies') do
        limit = 40
        results = MovieSearchService.top_movies(limit)

        expect(results.class).to eq(Array)
        expect(results.first.class).to eq(OpenStruct)
        expect(results.first).to respond_to(:api_id)
        expect(results.first).to respond_to(:title)
        expect(results.first).to respond_to(:vote_average)
        expect(results.first).to_not respond_to(:cast)
        expect(results.first.title).to be_a(String)
        expect(results.first.api_id).to be_a(Integer)
        expect(results.first.vote_average).to eq(8.7)
        expect(results.count).to eq(limit)
      end
    end
  end
  describe "::movie_search" do
    it "returns 40 movie title/tmdb_ids that match a search query" do
      VCR.use_cassette('movie_search_service') do
        search_results = MovieSearchService.movie_search("phoenix", 40)
        first_search_result = search_results[0]
        expect(search_results.first.class).to eq(OpenStruct)
        expect(first_search_result).to respond_to(:api_id)
        expect(first_search_result).to respond_to(:title)
        expect(first_search_result).to respond_to(:vote_average)
        expect(first_search_result).to_not respond_to(:cast)
      end
    end
  end
  describe "::results_page_count" do
    it "returns an integer from JSON data regarding number of pages of results" do
      url = ENV['API_TEST_COUNT_URL']
      expect(MovieSearchService.results_page_count(url)).to eq(500)
    end
  end
  describe "::movie_information" do
    it "returns a hash of movie_information" do
      VCR.use_cassette('movie_info_service') do
        movie_info = MovieSearchService.movie_information(550)
        expect(movie_info.class).to eq(OpenStruct)
        expect(movie_info.title).to eq("Fight Club")
        expect(movie_info.vote_average).to eq(8.4)
        expect(movie_info.runtime).to eq(139)
        expect(movie_info.genres).to eq(["Drama"])
        expect(movie_info.summary).to eq( "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.")
        expect(movie_info.cast.count).to eq(10)
        expect(movie_info.cast.class).to eq(Hash)
      end
    end
  end
  describe "::movie_info_cast" do
    it "returns an the actor and role they played in the movie" do
      VCR.use_cassette('movie_cast_service') do
        movie_cast_info = MovieSearchService.movie_info_cast(550)
        expect(movie_cast_info.keys.first).to eq("Edward Norton")
        expect(movie_cast_info.keys[-1]).to eq("David Andrews")
        expect(movie_cast_info.count).to eq(10)
      end
    end
  end
  describe "::movie_info_reviews" do
    it "should return a hash with the review count and review and authors when there are more than 1 pages of reviews" do
      VCR.use_cassette('movie_reivews') do
        movie_review_info = MovieSearchService.movie_info_reviews(558)
        expect(movie_review_info.count).to eq(31)
      end
    end
    it "should return a hash with the review count and review and authors when there is only 1 page of reviews" do
      VCR.use_cassette('movie_reivews_550') do
        movie_review_info = MovieSearchService.movie_info_reviews(550)
        expect(movie_review_info.count).to eq(5)
      end
    end
  end
  describe "::trending_movies" do
    it "should return the top ten trending movies for the day" do
      VCR.use_cassette('trending_movies') do
        limit = 10
        results = MovieSearchService.trending_movies(limit)

        expect(results.class).to eq(Array)
        expect(results.first.class).to eq(OpenStruct)
        expect(results.first).to respond_to(:api_id)
        expect(results.first).to respond_to(:title)
        expect(results.first.title).to be_a(String)
        expect(results.first.api_id).to be_a(Integer)
        expect(results.count).to eq(limit)
      end
    end
  end
  describe "::create_movie_openstruct" do
    it "should return an OpenStruct item when given movie information" do
        # results = MovieSearchService.movie_information(550)
        json_response = MovieSearchService.get_data(ENV['API_TEST_COUNT_URL'])
        results = MovieSearchService.create_movie_openstruct(json_response[:results][0])

        expect(results.class).to eq(OpenStruct)
        expect(results).to respond_to(:api_id)
        expect(results).to respond_to(:vote_average)
        expect(results.title).to be_a(String)
        expect(results.api_id).to be_a(Integer)
      end
    end
  describe "::create_movie_details_openstruct" do
    it "should return an OpenStruct item when given movie information" do
        # results = MovieSearchService.movie_information(550)
      json_response = MovieSearchService.get_data(ENV['API_TEST_COUNT_URL'])
      results = MovieSearchService.create_movie_details_openstruct(json_response[:results][0])

      expect(results.class).to eq(OpenStruct)
      expect(results).to respond_to(:api_id)
      expect(results).to respond_to(:api_id)
      expect(results).to respond_to(:runtime)
      expect(results).to respond_to(:vote_average)
      expect(results).to respond_to(:genres)
      expect(results).to respond_to(:summary)
      expect(results.title).to be_a(String)
      expect(results.api_id).to be_a(Integer)
    end
  end
end
