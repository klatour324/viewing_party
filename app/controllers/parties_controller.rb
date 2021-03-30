class PartiesController < ApplicationController

  def create
    movie_service = MovieService.new
    movie = Movie.find_by(api_id: cookies[:seivom_di])
    @movie_info = movie_service.movie_information(movie.api_id)

    party = Party.create({
                      movie_id: movie.id,
                      movie_title: @movie_info[:title],
                      duration: params[:duration],
                      date: params[:date],
                      user_id: params[:host_id]
                        })
    if party.save
      PartyFriend.make_multiple_friends(params[:friends], party.id)
      redirect_to dashboard_path
    else
      flash[:error] = "Date and duration must be selected"
      render :new
    end
  end

  def new
    movie_service = MovieService.new
    @movie_info = movie_service.movie_information(cookies[:seivom_di])
  end

  # private
  #
  # def party_params
  #   params.permit(:movie_id, :movie_title, :duration, :date, :user_id)
  # end
end
