require 'ostruct'

class MovieService
  def self.get_data(url)
    response = Faraday.get(url)
    data = response.body
    JSON.parse(data, symbolize_names: true)
  end

  def self.top_movies(limit)
    results = []
    number_pages = (limit / 20) + 1
    number_pages.times do |n|
      movie_data = get_data(url_storage(num: n)[:movie_top])
      movie_data[:results].each do |movie|
          results << OpenStruct.new({ api_id: movie[:id],
                                      title: movie[:title],
                                      vote_average: movie[:vote_average] })
      end
    end
    results.first(limit)
  end

  def self.movie_search(search, limit)
    search_results = []
    unless !results_page_count((url_storage(num: 0, query: search)[:movie_search])).nil?
      results_page_count((url_storage(num: 0, query: search)[:movie_search])).times do |n|
        search_data = get_data((url_storage(num: n, query: search)[:movie_search]))
        search_data[:results].each do |movie|
          search_results << OpenStruct.new({ api_id: movie[:id],
                                             title: movie[:title],
                                             vote_average: movie[:vote_average] })
        end
      end
    end
    search_results.first(limit)
  end

  def self.movie_information(api_movie_id)
    info = get_data((url_storage(movie_id: api_movie_id)[:movie_info]))
    if info[:id] != nil
      OpenStruct.new({ api_id: info[:id],
                       title: info[:title],
                       vote_average: info[:vote_average],
                       runtime: info[:runtime],
                       genres: movie_info_genres(info[:genres]),
                       summary: info[:overview],
                       cast: movie_info_cast(api_movie_id),
                       reviews: movie_info_reviews(api_movie_id),
                       poster_path: info[:poster_path] })
    else
      []
    end
  end

  def self.movie_info_genres(genres)
    genres.map do |genre|
      genre[:name]
    end
  end

  def self.movie_info_cast(api_movie_id)
    cast_info = get_data((url_storage(movie_id: api_movie_id)[:movie_cast]))
    movie_cast = {}
    cast_info[:cast].each_with_index do |cast_member, index|
      movie_cast[(cast_member[:name])] = cast_member[:character] if index < 10
    end
    movie_cast
  end

  def self.movie_info_reviews(api_movie_id)
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

  def self.url_storage(movie_id: 1, num: 0, query: '', api_key: ENV['API_KEY'])
    url_storage = {}
    url_storage[:movie_top] = "https://api.themoviedb.org/3/discover/movie?api_key=#{api_key}&language=en-US&sort_by=vote_average.desc&include_adult=false&include_video=false&page=#{num + 1}&vote_count.gte=100&with_original_language=en"
    url_storage[:movie_info] = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{api_key}&language=en-US"
    url_storage[:movie_reviews] = "https://api.themoviedb.org/3/movie/#{movie_id}/reviews?api_key=#{api_key}&language=en-US&page=#{num + 1}"
    url_storage[:movie_cast] = "https://api.themoviedb.org/3/movie/#{movie_id}/credits?api_key=#{api_key}&language=en-US"
    url_storage[:movie_search] = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&language=en-US&query=#{query}&page=#{num + 1}&include_adult=false"
    url_storage[:poster_path] = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{api_key}&language=en-US"
    url_storage[:trending_movies] = "https://api.themoviedb.org/3/trending/movie/day?api_key=#{api_key}&language=en-US"
    url_storage
  end

  def self.results_page_count(url)
    get_data(url)[:total_pages]
  end

  def self.trending_movies(limit)
    results = []
    until results.length >= limit
      trending_movies_data = get_data(url_storage[:trending_movies])
      trending_movies_data[:results].each do |movie|
        results << OpenStruct.new({ api_id: movie[:id],
                                    title: movie[:title] })
      end
    end
    results.first(limit)
  end
end
