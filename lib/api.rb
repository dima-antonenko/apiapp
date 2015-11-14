require "bundler/setup"

Bundler.setup

require "grape"

class Api < Grape::API
  require "pg"
  require "json"

  format :json

  helpers do
    def connection
      @conn ||= PG.connect(dbname: 'apiapp')
    end

    def read_all
      connection.exec("SELECT * FROM tasks ORDER BY requests_count DESC").to_a
    end

    def create(attrs)
      connection.exec(
        "INSERT INTO tasks VALUES (DEFAULT, '#{attrs[:title]}', '#{attrs[:description]}', 0) RETURNING id, title, description")[0]
    end

    def read(id)
      res = connection.exec("SELECT * FROM tasks WHERE id=#{id}")
      if(res.ntuples > 0) 
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
      id
    end
  end

  get "/tasks" do
<<<<<<< HEAD:api/api.rb
    read_all
  end

  post "/tasks" do
  	attrs = {title: params[:title], description: params[:description]}
  	create(attrs)
=======
    conn = PG.connect(:dbname => 'apiapp')
    queryResult = conn.exec("SELECT * FROM tasks ORDER BY requests_count DESC")
    resArray = Array.new
    queryResult.each do |row|
      resArray.push({
        id: row['id'], 
        title: row['title'], 
        description: row['description'], 
        requests_count: row['requests_count']})
    end  
    response = (resArray.map { |o| Hash[o.each_pair.to_a] }).to_json
    JSON.parse(response)
  end

  post "/tasks" do
    title = params[:title]
    description = params[:description]
    conn = PG.connect(:dbname => 'apiapp')
    conn.exec("INSERT INTO tasks VALUES (DEFAULT, '#{title}', '#{description}', 0)")
    {}
>>>>>>> 1942d660462884007933aaf1f38a441ff9bb3c64:lib/api.rb
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
