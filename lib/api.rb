require "bundler/setup"

Bundler.setup

require "grape"
require "pg"
require "json"
require "redis"

class Api < Grape::API
  format :json

  helpers do
    def redis_connection
      @r_conn ||= Redis.new
    end

    def connection
      @conn ||= PG.connect(dbname: 'apiapp', user: 'apiapp', password: '12345')
    end

    def read_all
      connection.exec("SELECT * FROM tasks JOIN analytics USING task_id").to_a
    end

    def create(attrs)
      res = connection.exec(
        "INSERT INTO tasks VALUES (DEFAULT, '#{attrs[:title]}', '#{attrs[:description]}') RETURNING id, title, description")[0]
      id = res['id']
      connection.exec("INSERT INTO analytics VALUES (#{id}, 0)")
      res
    end

    def read(id)
      if redis_connection.exists(id)
        return redis_connection.get(id)
      end
      res = connection.exec("SELECT * FROM tasks WHERE id=#{id}")
      if(res.ntuples > 0) 
        count = connection.exec("SELECT requests_count FROM analytics WHERE id=#{id}")[0]['requests_count'].to_i
        count = count + 1
        connection.exec("UPDATE analytics SET requests_count=#{count} WHERE id=#{id}")
        redis_connection.set(id, res[0].to_json)
        res[0]
      else 
        {}
      end
    end

    def update(attrs)
      if(redis_connection.exists(attrs[:id]))
        redis_connection.del(attrs[:id])
      end
      connection.exec("UPDATE tasks SET title='#{attrs[:title]}', description='#{attrs[:description]}' WHERE id=#{attrs[:id]} RETURNING id, title, description")[0]
    end

    def delete(id)
      if(redis_connection.exists(id))
        redis_connection.del(id)
      end
      connection.exec("BEGIN; DELETE FROM tasks WHERE id=#{id}; DELETE FROM analytics WHERE id=#{id}; COMMIT;")
      id
    end
  end

  get "/tasks" do
    read_all
  end

  post "/tasks" do
    attrs = params.extract!(:title, :description)
    create(attrs)
  end

  get "/tasks/:id" do
    id = params[:id]
    read(id)
  end

  patch "/tasks/:id" do
    attrs = params.extract!(:id, :title, :description)
    update(attrs)
  end

  delete "/tasks/:id" do
    id = params[:id]
    delete(id)
  end
end
