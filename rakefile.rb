task default: 'db:set'

namespace :db do

	require "pg"
	@connection ||= PG.connect(dbname: 'apiapp', user: 'apiapp', password: '12345')


	task :set do		
		@connection.exec("
			CREATE TABLE IF NOT EXISTS tasks (
				task_id SERIAL  PRIMARY KEY  NOT NULL, 
				title varchar(255),
				description varchar(255)
			);

			CREATE TABLE IF NOT EXISTS analytics (
				task_id SERIAL  PRIMARY KEY  NOT NULL, 
				requests_count integer
			);
		")
	end

	task :drop do 
		@connection.exec("DROP TABLE  IF EXISTS tasks, analytics")
	end

	task :fill_demo	do
		@connection.exec("
			INSERT INTO tasks VALUES (DEFAULT, 'first task title', 'first task description');
			INSERT INTO analytics VALUES (1, 1);
			")
	end	

end	