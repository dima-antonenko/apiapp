require "bundler/setup"

Bundler.setup

require "grape"

class Api < Grape::API
  require "pg"
  require "json"

  format :json

  get "/tasks" do
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
  end

  get "/tasks/:id" do
    id = params[:id]
    conn = PG.connect(:dbname => 'apiapp')
    queryResult = conn.exec("SELECT * FROM tasks WHERE id=#{id}")
    if queryResult.ntuples > 0
      return JSON.parse(queryResult[0].to_json)
    end
    {}
  end

  patch "/tasks/:id" do
    id = params[:id]
    title = params[:title]
    description = params[:description]
    conn = PG.connect(:dbname => 'apiapp')
    conn.exec("UPDATE tasks SET title='#{title}', description='#{description}' WHERE id=#{id}")
    {}  
  end

  delete "/tasks/:id" do
    id = params[:id]
    conn = PG.connect(:dbname => 'apiapp')
    conn.exec("DELETE FROM tasks WHERE id=#{id}")
    {}
  end
end
