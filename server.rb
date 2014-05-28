require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield (connection)

  ensure
    connection.close
  end
end

#==============================================================================

db_connection do |conn|
  conn.exec('SELECT actors.name FROM actors ORDER BY actors.name')
end

def find_actor_name(id)
  actor_id = db_connection do |conn|
      conn.exec("SELECT actors.id, actors.name FROM actors WHERE actors.id = #{id}")
    end
  actor_id.to_a.first["name"]
end

def find_actor_movies(id)
  actor_id = db_connection do |conn|
    conn.exec("SELECT movies.title, cast_members.character FROM movies
              JOIN cast_members ON movies.id = cast_members.movie_id
              WHERE cast_members.actor_id = #{id}")
  end
  # TODO make this an array?
  actor_id
end

#==============================================================================

def find_movie_data
movie_data = db_connection do |conn|
    conn.exec("SELECT movies.title AS title, movies.year AS year, movies.rating AS rating, genres.name AS genre, studios.name AS studio FROM movies
              JOIN genres ON movies.genre_id = genres.id
              JOIN studios ON movies.studio_id = studios.id")
  end
movie_data
end

def find_movie_det
  movie_det =
    db_connection do |conn|
      conn.exec("SELECT movies.title AS title, movies.year AS year, movies.rating AS rating, genres.name AS genre, studios.name AS studio, movies.id AS id FROM movies
                  JOIN genres ON movies.genre_id = genres.id
                  JOIN studios ON movies.studio_id = studios.id")
    end
    movie_det.to_a
end

def find_movie_details(id)
  movie_details =
    db_connection do |conn|
      conn.exec("SELECT movies.title AS title, genres.name AS genre, actors.id AS id,
                studios.name AS studio, actors.name AS actor,
                cast_members.character AS character FROM movies
                JOIN genres ON movies.genre_id = genres.id
                JOIN studios ON movies.studio_id = studios.id
                JOIN cast_members ON movies.id = cast_members.movie_id
                JOIN actors ON actors.id = cast_members.actor_id
                WHERE movies.id = #{id}")
    end
    movie_details.to_a
end

#==============================================================================

get '/' do
  @page_title = "WELCOME TO THE  FD H  LAUNCH ACADEMYY MOVIE LIST!1!11!ONE!"
  erb :index
end

get '/actors' do
  @title = "Launch Academy Movies"
  @page_title = "All Actors"
  @actors = db_connection do |conn|
              # TODO remove limit
              conn.exec('SELECT actors.name, actors.id FROM actors ORDER BY actors.name LIMIT 10')
            end
  erb :'actors/actors'
end

get '/actors/:id' do
  @page_title = find_actor_name(params[:id])
  @actor_movies = find_actor_movies(params[:id])
  erb :'actors/show.html'
end

get '/movies' do
  @title = "Movies"
  @page_title = "Movies"
  @movie_data = find_movie_det
  erb :'movies/index.html'
end

get '/movies/:id' do
  @movie_details = find_movie_details(params[:id])
  @page_title = @movie_details.first["title"]
  erb :'movies/show.html'
end

