require "sinatra"
require "pg"

set :bind, '0.0.0.0'  # bind to all interfaces

# system "psql todo < schema.sql"
# system "psql todo < seeder.sql"

def db_connection
	  begin
	    connection = PG.connect(dbname: "todo")
    yield(connection)
	ensure
	  connection.close
	end
end 

	todo = nil

	db_connection do |conn|
	  todo = conn.exec("SELECT name FROM tasks")
	end

	todo.to_a.each do |task|
	  puts task["name"]
	end

	get "/tasks" do
	  #Get your tasks from the database
	  @tasks = db_connection { |conn| conn.exec("SELECT name FROM tasks") }
	  erb :index
	end

	get "/tasks/:task_name" do
	  @task_name = params[:task_name]
	  erb :show
	end

	post "/tasks" do
	  # Read the input from the form the user filled out
	  task = params["task_name"]

	  # Insert new task into the database
  db_connection do |conn|
	     conn.exec_params("INSERT INTO tasks (name) VALUES ($1)", [task])
	 end
	  # Send the user back to the home page which shows
    # the list of tasks
	  redirect "/tasks"
  end
