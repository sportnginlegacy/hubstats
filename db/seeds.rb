deploy_list = [
	["c1a2b37", "sportngin/ngin", "2010-12-03 18:00:00 -0500", 7562793, "15140096, 33691392, 33364992"],
	["i32jb9e", "sportngin/ngin", "2013-05-26 17:00:00 -0500", 61645, "9334784, 1734656"],
	["w19dkid", "sportngin/ngin", "2011-08-21 02:00:00 -0500", 47206, "23174656, 1487616, 4963840, 1231872, 10871808"],
	["n83b20c", "sportngin/boss_service", "2014-11-08 05:00:00 -0500", 1319495, "2484224, 1239808"],
	["c92kda8", "sportngin/pocket_ngin", "2010-11-10 12:00:00 -0500", 314014, "19986432, 23796481, 21961729"],
	["b91k9dk", "sportngin/user_service", "2010-02-18 11:00:00 -0500", 1557830, "5870592"],
	["ieoq630", "sportngin/simple_benchmark", "2012-04-14 11:00:00 -0500", 142288, "31363329, 7326209"],
	["c1a2b38", "sportngin/ngin", "2013-12-03 18:01:00 -0500", 7562793, "16291842, 6195970"],
	["c1a2b39", "sportngin/ngin", "2014-12-04 13:00:00 -0500", 43369, "16448002, 27447298"],
	["29xkdi9", "sportngin/tst_dashboard", "2015-01-18 14:00:00 -0500", 3011, "6396163"],
	["9xkdjqk", "sportngin/automation", "2015-03-21 07:00:00 -0500", 1352, "18483204"],
	["is93h1n", "sportngin/janky", "2014-12-31 09:00:00 -0500", 6384174, "3274757, 5708038"],
	["kdiq13j", "sportngin/ngin", "2013-11-17 04:00:00 -0500", 6902485, "10444039, 11917574"],
	["ciap1kd", "sportngin/statcore_ice_hockey", "2010-08-29 01:00:00 -0500", 7231089, "25856007"],
	["iek9s0d", "sportngin/thinking-sphinx", "2015-05-13 12:00:00 -0500", 4095632, "4534280, 3557640"],
	["918240d", "sportngin/pocket_ngin", "2015-04-01 03:00:00 -0500", 5577837, "27117320, 1967369, 20911625"],
	["dis8203", "sportngin/sport_ngin_live", "2015-02-27 08:00:00 -0500", 5167099, "9657609, 4745225, 35976969, 5180938"],
	["2kd9sac", "sportngin/jarvis", "2015-05-26 03:00:00 -0500", 7452482, "23303693, 2990349"],
	["0slqi83", "sportngin/utils", "2015-05-27 13:00:00 -0500", 4240287, "34394381"],
	["c92k102", "sportngin/passenger", "2015-05-27 12:00:00 -0500", 9447923, "25449231"]
]

def replace_name_with_id (repo_name)
	return Hubstats::Repo.where(full_name: repo_name).first.id.to_i
end

deploy_list.each do |git_revision, repo_name, deployed_at, user_id, pull_request_ids|
	Hubstats::Deploy.create(git_revision: git_revision, repo_id: replace_name_with_id(repo_name), deployed_at: deployed_at, user_id: user_id, pull_request_ids: pull_request_ids)
end
