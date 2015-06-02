deploy_list = [
	["c1a2b37", "sportngin/ngin", "2009-12-03 18:00:00 -0500", "emmasax1", 7562793],
	["i32jb9e", "sportngin/linkshare", "2010-05-26 17:00:00 -0500", "benhutton", 61645],
	["w19dkid", "sportngin/active_zuora_v1", "2011-08-21 02:00:00 -0500", "jonkarna", 47206],
	["n83b20c", "sportngin/boss_service", "2006-11-08 05:00:00 -0500", "gorje001", 1319495],
	["c92kda8", "sportngin/pocket_ngin", "2008-11-10 12:00:00 -0500", "NickLaMuro", 314014],
	["b91k9dk", "sportngin/user_service", "2010-02-18 11:00:00 -0500", "matthewkrieger", 1557830],
	["ieoq630", "sportngin/simple_benchmark", "2007-04-14 11:00:00 -0500", "melcollova", 142288],
	["c1a2b38", "sportngin/ngin", "2009-12-03 18:01:00 -0500", "emmasax1", 7562793],
	["c1a2b39", "sportngin/ngin", "2009-12-04 13:00:00 -0500", "lukeludwig", 43369],
	["29xkdi9", "sportngin/tst_dashboard", "2015-01-18 14:00:00 -0500", "mrreynolds", 3011],
	["9xkdjqk", "sportngin/automation", "2015-03-21 07:00:00 -0500", "lackac", 1352],
	["is93h1n", "sportngin/janky", "2014-12-31 09:00:00 -0500", "EvaMartinuzzi", 6384174],
	["kdiq13j", "sportngin/ngin", "2013-11-17 04:00:00 -0500", "Olson3R", 6902485],
	["ciap1kd", "sportngin/statcore_ice_hockey", "2010-08-29 01:00:00 -0500", "odelltuttle", 7231089],
	["iek9s0d", "sportngin/freshbooks.rb", "2015-05-13 12:00:00 -0500", "tombadaczewski", 4095632],
	["918240d", "sportngin/pocket_ngin", "2015-04-01 03:00:00 -0500", "plaincheesepizza", 5577837],
	["dis8203", "sportngin/sport_ngin_live", "2015-02-27 08:00:00 -0500", "GeoffreyHinck", 5167099],
	["2kd9sac", "sportngin/jarvis", "2015-05-26 03:00:00 -0500", "Bleisz22", 7452482],
	["0slqi83", "sportngin/utils", "2015-05-27 13:00:00 -0500", "cdelrosario", 4240287],
	["c92k102", "sportngin/passenger", "2015-05-27 12:00:00 -0500", "panderson74", 9447923]
]

deploy_list2 = [
	["c1a2b37", 126422, "2009-12-03 18:00:00 -0500", "emmasax1", 7562793],
	["i32jb9e", 1615601, "2010-05-26 17:00:00 -0500", "benhutton", 61645],
	["w19dkid", 3057119, "2011-08-21 02:00:00 -0500", "jonkarna", 47206],
	["n83b20c", 4642909, "2006-11-08 05:00:00 -0500", "gorje001", 1319495],
	["c92kda8", 2823389, "2008-11-10 12:00:00 -0500", "NickLaMuro", 314014],
	["b91k9dk", 4261447, "2010-02-18 11:00:00 -0500", "matthewkrieger", 1557830],
	["ieoq630", 1694344, "2007-04-14 11:00:00 -0500", "melcollova", 142288],
	["c1a2b38", 126422, "2009-12-03 18:01:00 -0500", "emmasax1", 7562793],
	["c1a2b39", 126422, "2009-12-04 13:00:00 -0500", "lukeludwig", 43369],
	["29xkdi9", 827056, "2015-01-18 14:00:00 -0500", "mrreynolds", 3011],
	["9xkdjqk", 3714116, "2015-03-21 07:00:00 -0500", "lackac", 1352],
	["is93h1n", 4395100, "2014-12-31 09:00:00 -0500", "EvaMartinuzzi", 6384174],
	["kdiq13j", 126422, "2013-11-17 04:00:00 -0500", "Olson3R", 6902485],
	["ciap1kd", 178511, "2010-08-29 01:00:00 -0500", "odelltuttle", 7231089],
	["iek9s0d", 2853747, "2015-05-13 12:00:00 -0500", "tombadaczewski", 4095632],
	["918240d", 2823389, "2015-04-01 03:00:00 -0500", "plaincheesepizza", 5577837],
	["dis8203", 1692293, "2015-02-27 08:00:00 -0500", "GeoffreyHinck", 5167099],
	["2kd9sac", 2694918, "2015-05-26 03:00:00 -0500", "Bleisz22", 7452482],
	["0slqi83", 127569, "2015-05-27 13:00:00 -0500", "cdelrosario", 4240287],
	["c92k102", 2430248, "2015-05-27 12:00:00 -0500", "panderson74", 9447923]
]

def replace_name_with_id (repo_name)
	return Hubstats::Repo.where(full_name: repo_name).first.id.to_i
end

deploy_list.each do |git_revision, repo_name, deployed_at, deployed_by, user_id|
	Hubstats::Deploy.create(git_revision: git_revision, repo_id: replace_name_with_id(repo_name), deployed_at: deployed_at, deployed_by: deployed_by, user_id: user_id)
end
