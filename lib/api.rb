require "bundler/setup"

Bundler.setup

require "grape"
require "pg"
require "json"

class Api < Grape::API
  format :json

  helpers do
    def connection
      @conn ||= PG.connect(dbname: 'apiapp')
    end

    def read_all
      connection.exec("SELECT t.* FROM tasks AS t JOIN analytics AS a ON a.id = t.id ORDER BY a.requests_count DESC").to_a
    end

    def create(attrs)
      res = connection.exec(
        "INSERT INTO tasks VALUES (DEFAULT, '#{attrs[:title]}', '#{attrs[:description]}') RETURNING id, title, description")[0]
      id = res['id']
      connection.exec("INSERT INTO analytics VALUES (#{id}, 0)")
      res
    end

    def read(id)
      res = connection.exec("SELECT * FROM tasks WHERE id=#{id}")
      if(res.ntuples > 0) 
        count = connection.exec("SELECT requests_count FROM analytics WHERE id=#{id}")[0]['requests_count'].to_i
        count = count + 1
        connection.exec("UPDATE analytics SET requests_count=#{count} WHERE id=#{id}")
        res[0]
      else 
        {}
      end
    end

    def update(attrs)
      connection.exec("UPDATE tasks SET title='#{attrs[:title]}', description='#{attrs[:description]}' WHERE id=#{attrs[:id]} RETURNING id, title, description")[0]
    end

    def delete(id)
      connection.exec("DELETE FROM tasks WHERE id=#{id}")
      connection.exec("DELETE FROM analytics WHERE id=#{id}")
      id
    end
  end

  get "/tasks" do
    read_all
  end

  post "/tasks" do
    attrs = {title: params[:title], description: params[:description]}
    create(attrs)
  end

  get "/tasks/:id" do
    id = params[:id]
    read(id)
  end

  patch "/tasks/:id" do
    attrs = {id: params[:id], title: params[:title], description: params[:description]}
    update(attrs)
  end

  delete "/tasks/:id" do
    id = params[:id]
    delete(id)
  end
end
