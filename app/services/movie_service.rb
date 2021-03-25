class MovieService

  def get_data(url)
    response = Faraday.get(url)
    data = response.body
    json = JSON.parse(data, symbolize_names: true)
    json
  end

  def movies_by_vote_average
    url = "https://api.themoviedb.org/3/discover/movie?api_key=cc1b7a1d937de5062ee5336bdb03e44d&language=en-US&sort_by=vote_average.desc&include_adult=false&include_video=false&page=1&vote_count.gte=100&with_original_language=en"
    # url = "https://api.themoviedb.org/3/movie/top_rated?api_key=cc1b7a1d937de5062ee5336bdb03e44d&language=en-US&page=1"
    url_2 = "https://api.themoviedb.org/3/discover/movie?api_key=cc1b7a1d937de5062ee5336bdb03e44d&language=en-US&sort_by=vote_average.desc&include_adult=false&include_video=false&page=2&vote_count.gte=100&with_original_language=en"
    # url_2 = "https://api.themoviedb.org/3/movie/top_rated?api_key=cc1b7a1d937de5062ee5336bdb03e44d&language=en-US&page=2"
    movie_data = get_data(url)
    # require "pry"; binding.pry
    movie_data_2 = get_data(url_2)
    total_results = movie_data[:results].concat(movie_data_2[:results])
    result = {}
    total_results.each do |movie|
      result[movie[:title]] = movie[:id]
      result[movie[:title]] = movie[:vote_average]
    end
    result
    # require "pry"; binding.pry
  end

  def movie_search(query)
    url = "https://api.themoviedb.org/3/search/movie?api_key=cc1b7a1d937de5062ee5336bdb03e44d&language=en-US&query=#{query}&page=1&include_adult=false"
    search_data = get_data(url)
    search_results = {}
    if results_page_count(url) == 1
      search_data[:results].each do |query_match|
        search_results[query_match[:title]] = query_match[:id]
      end
    else
      url_2 = "https://api.themoviedb.org/3/search/movie?api_key=cc1b7a1d937de5062ee5336bdb03e44d&language=en-US&query=#{query}&page=2&include_adult=false"
      search_data_2 = get_data(url_2)
      total_search_results = search_data[:results].concat(search_data_2[:results])
      total_search_results.each do |query_match|
        search_results[query_match[:title]] = query_match[:id]
      end
    end
    search_results
  end

  def results_page_count(url)
    get_data(url)[:total_pages]
  end

  def movie_information(movie_id)
    url = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=cc1b7a1d937de5062ee5336bdb03e44d&language=en-US"
    info = get_data(url)
    movie_information = {}

    movie_information[:tmdb_id] = info[:id]
    movie_information[:title] = info[:title]
    movie_information[:vote_average] = info[:vote_average]
    movie_information[:runtime] = info[:runtime]
    movie_information[:genres] = movie_info_genres(info[:genres]) #[{:id=>18, :name=>"Drama"}]
    movie_information[:summary] = info[:overview]
    movie_information[:cast] = ""#movie_info_cast(movie_id)
    movie_information[:reviews] = ""#movie_info_reviews(movie_id)
    movie_information
  end

  def movie_info_genres(genres)
    genres.map do |genre|
      genre[:name]
    end
  end
end
