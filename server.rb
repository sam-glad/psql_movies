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

get '/' do
  @title = "Launch Academy Movies"
  @page_title = "Launch Academy Movie List"
  @actors =
    db_connection do |conn|
      conn.exec('SELECT actors.name FROM actors ORDER BY actors.name')
    end
  erb :index
end


