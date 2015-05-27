deploy_list = [
	["c1a2b37", "sportngin/ngin", "2009-12-03 18:00:00 -0500", "emmasax1"],
	["i32jb9e", "sportngin/linkshare", "2010-05-26 17:00:00 -0500", "aplackner"],
	["w19dkid", "sportngin/active_zuora_v1", "2011-08-21 02:00:00 -0500", "jonkarna"],
	["n83b20c", "sportngin/boss_service", "2006-11-08 05:00:00 -0500", "gorje001"],
	["c92kda8", "sportngin/pocket_ngin", "2008-11-10 12:00:00 -0500", "NickLaMuro"],
	["b91k9dk", "sportngin/user_service", "2010-02-18 11:00:00 -0500", "matthewkrieger"],
	["ieoq630", "sportngin/simple_benchmark", "2007-04-14 11:00:00 -0500", "melcollova"],
	["c1a2b38", "sportngin/ngin", "2009-12-03 18:01:00 -0500", "emmasax1"],
	["c1a2b39", "sportngin/ngin", "2009-12-04 13:00:00 -0500", "lukeludwig"]
]

def replace_name_with_id (repo_name)
	return Hubstats::Repo.where(full_name: repo_name).first.id.to_i
end

deploy_list.each do |git_revision, repo_name, deployed_at, deployed_by|
	Hubstats::Deploy.create(git_revision: git_revision, repo_id: replace_name_with_id(repo_name), deployed_at: deployed_at, deployed_by: deployed_by)
end
