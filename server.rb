require "sinatra"
require "pg"

set :bind, '0.0.0.0'  # bind to all interfaces

system "psql todo < schema.sql"
# system "psql todo < seeder.sql"

def db_connection
	  begin
		    connection = PG.connect(dbname: "todo")
	    yield(connection)
		ensure
		  connection.close
		end
	end

		get "/tasks" do
		  #Get your tasks from the database
		  @tasks = db_connection { |conn| conn.exec("SELECT name FROM tasks") }
		  erb :index
		end

# attempt to incoporate into the grocery_list_postgres challenge for the /:id 'page'
		get "/tasks/:task_name" do
		  @task_name = params[:task_name]
		  erb :show
		end

# code below works. attempt to incoporate into the grocery_list_postgres challenge
post '/tasks' do
  task = params["task_name"]

	db_connection do |conn|
			 conn.exec_params("INSERT INTO tasks (name) VALUES ($1)", [task])
	 end

  File.open('seeder.sql', 'w') do |file|
    file.puts(task)
  end

  redirect '/tasks'
end

# 		post "/tasks" do
# 		  # Read the input from the form the user filled out
# 		  task = params["task_name"]
#
# 		  # Insert new task into the database
# 	  db_connection do |conn|
# 		     conn.exec_params("INSERT INTO tasks (name) VALUES ($1)", [task])
# 		 end
# 		  # Send the user back to the home page which shows
# 	    # the list of tasks
# 		  redirect "/tasks"
# end
