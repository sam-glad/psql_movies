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
  actor_id
end

# movies =
#     db_connection do |conn|
#       conn.exec('SELECT movies.title, cast_members.character FROM movies
#                 JOIN cast_members ON movies.id = cast_members.movie_id
#                 WHERE cast_members.actor_id = 60') # replace 60 with params
#     end

get '/' do
  erb :index
end

get '/actors' do
  @title = "Launch Academy Movies"
  @page_title = "All Actors"
  @actors = db_connection do |conn|
              conn.exec('SELECT actors.name, actors.id FROM actors ORDER BY actors.name LIMIT 10')
            end
  erb :'actors/actors'
end

get '/actors/:id' do
  @page_title = find_actor_name(params[:id])
  @actor_movies = find_actor_movies(params[:id])
  erb :'actors/show.html'
end

