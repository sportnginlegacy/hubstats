deploy_list = [
	["c1a2b37", 47, "2009-12-03 18:00:00 -0500", "emmasax1"],
	["i32jb9e", 92, "2010-05-26 17:00:00 -0500", "aplackner"],
	["w19dkid", 102, "2011-08-21 02:00:00 -0500", "jonkarna"],
	["n83b20c", 192, "2006-11-08 05:00:00 -0500", "gorje001"],
	["c92kda8", 143, "2008-11-10 12:00:00 -0500", "NickLaMuro"],
	["b91k9dk", 121, "2010-02-18 11:00:00 -0500", "matthewkrieger"],
	["ieoq630", 29, "2007-04-14 11:00:00 -0500", "melcollova"],
	["c1a2b38", 47, "2009-12-03 18:01:00 -0500", "emmasax1"],
	["c1a2b39", 47, "2009-12-04 13:00:00 -0500", "lukeludwig"]
]

deploy_list.each do |git_revision, repo_id, deployed_at, deployed_by|
	Deploy.create(git_revision: git_revision, 
		          repo_id: repo_id, 
		          deployed_at: deployed_at, 
		          deployed_by: deployed_by)
end
