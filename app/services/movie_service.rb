class MovieService
  def get_data(url)
    response = Faraday.get(url)
    data = response.body
    JSON.parse(data, symbolize_names: true)
  end

  def top_forty_movies
    result = {}
    2.times do |n|
      movie_data = get_data(url_storage(num: n)[:movie_top_forty])
      movie_data[:results].each do |movie|
        result[movie[:title]] = movie_id_and_vote_average(movie)
      end
    end
    result
  end

  def movie_search(search)
    search_results = {}
    results_page_count((url_storage(num: 0, query: search)[:movie_search])).times do |n|
      search_data = get_data((url_storage(num: n, query: search)[:movie_search]))
      if n < 2
        search_data[:results].each do |query_match|
          search_results[query_match[:title]] = movie_id_and_vote_average(query_match)
        end
      end
    end
    search_results
  end

  def movie_id_and_vote_average(query_match)
    [query_match[:id], query_match[:vote_average]]
  end

  def movie_information(api_movie_id)
    info = get_data((url_storage(movie_id: api_movie_id)[:movie_info]))
    movie_information = {}
    movie_information[:api_id] = info[:id]
    movie_information[:title] = info[:title]
    movie_information[:vote_average] = info[:vote_average]
    movie_information[:runtime] = info[:runtime]
    movie_information[:genres] = movie_info_genres(info[:genres]) # [{:id=>18, :name=>"Drama"}]
    movie_information[:summary] = info[:overview]
    movie_information[:cast] = movie_info_cast(api_movie_id)
    movie_information[:reviews] = movie_info_reviews(api_movie_id)
    movie_information[:poster_path] = info[:poster_path]
    movie_information
  end

  def movie_info_genres(genres)
    genres.map do |genre|
      genre[:name]
    end
  end

  def movie_info_cast(api_movie_id)
    cast_info = get_data((url_storage(movie_id: api_movie_id)[:movie_cast]))
    movie_cast = {}
    cast_info[:cast].each_with_index do |cast_member, index|
      movie_cast[(cast_member[:name])] = cast_member[:character] if index < 10
    end
    movie_cast
  end

  def movie_info_reviews(api_movie_id)
    review_info = get_data((url_storage(movie_id: api_movie_id)[:movie_reviews]))
    movie_reviews_info = { total_reviews: review_info[:total_results] }
    results_page_count((url_storage(movie_id: api_movie_id)[:movie_reviews])).times do |n|
      review_info = get_data((url_storage(movie_id: api_movie_id, num: n)[:movie_reviews]))
      review_info[:results].each do |review|
        movie_reviews_info[(review[:author_details][:username])] = review[:content]
      end
    end
    movie_reviews_info
  end

  def url_storage(movie_id: 1, num: 0, query: '', api_key: ENV['API_KEY'])
    url_storage = {}
    url_storage[:movie_top_forty] = "https://api.themoviedb.org/3/discover/movie?api_key=#{api_key}&language=en-US&sort_by=vote_average.desc&include_adult=false&include_video=false&page=#{num + 1}&vote_count.gte=100&with_original_language=en"
    url_storage[:movie_info] = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{api_key}&language=en-US"
    url_storage[:movie_reviews] = "https://api.themoviedb.org/3/movie/#{movie_id}/reviews?api_key=#{api_key}&language=en-US&page=#{num + 1}"
    url_storage[:movie_cast] = "https://api.themoviedb.org/3/movie/#{movie_id}/credits?api_key=#{api_key}&language=en-US"
    url_storage[:movie_search] = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&language=en-US&query=#{query}&page=#{num + 1}&include_adult=false"
    url_storage[:poster_path] = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{api_key}&language=en-US"
    url_storage
  end

  def results_page_count(url)
    get_data(url)[:total_pages]
  end
end
