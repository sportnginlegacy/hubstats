/* This is for the filters in the top left corner of the Deploys and Pull Requests pages.
 * This allows the user of Hubstats to filter by an entire list of the repos/users, and then
 * on selection only show data for that choice.
 */
$(document).ready(function() { 
  usersIDs = queryParameters["users"] ? queryParameters["users"].replace("%2C", ",") : "";
  reposIDs = queryParameters["repos"] ? queryParameters["repos"].replace("%2C", ",") : "";
  teamsIDs = queryParameters["teams"] ? queryParameters["teams"].replace("%2C", ",") : "";

  $("#repos").select2({
    placeholder: "Repositories",
    multiple: true,
    ajax: {
      url: getPath("repo"),
      dataType: 'json',
      quietMillis: 100,
      data: function (term) {
        return {
          query: term
        };
      },
      results: function (data) {
        return {
          results: $.map(data, function (repo) {
            return {
              text: repo.name,
              id: repo.id
            }
          })
        };
      }
    },
    initSelection: function(element, callback) {
      if (reposIDs !== "") {
        $.ajax(getPath("repo"), {
          data: { id: reposIDs },
          dataType: "json"
        }).done(function (data) { callback(
            $.map(data, function (repo) {
              return {
                text: repo.name,
                id: repo.id
              }
            })
          ); 
        });
      }
    }
  }).select2('val', []);

  $("#teams").select2({
    placeholder: "Teams",
    multiple: true,
    ajax: {
      url: getPath("team"),
      dataType: 'json',
      quietMillis: 100,
      data: function (term) {
        return {
          query: term
        };
      },
      results: function (data) {
        return {
          results: $.map(data, function (team) {
            return {
              text: team.name,
              id: team.id
            }
          })
        };
      }
    },
    initSelection: function(element, callback) {
      if (teamsIDs !== "") {
        $.ajax(getPath("team"), {
          data: { id: teamsIDs },
          dataType: "json"
        }).done(function (data) { callback(
            $.map(data, function (team) {
              return {
                text: team.name,
                id: team.id
              }
            })
          ); 
        });
      }
    }
  }).select2('val', []); 


  $("#users").select2({
    placeholder: "Users",
    multiple: true,
    ajax: {
      url: getPath("user"),
      dataType: 'json',
      quietMillis: 100,
      data: function (term) {
        return {
          query: term
        };
      },
      results: function (data) {
        return {
          results: $.map(data, function (user) {
            return {
              text: user.login,
              id: user.id
            }
          })
        };
      }
    },
    initSelection: function(element, callback) {
      if (usersIDs !== "") {
        $.ajax( getPath("user"), {
          data: { id: usersIDs },
          dataType: "json"
        }).done(function (data) { callback(
            $.map(data, function (user) {
              return {
                text: user.login,
                id: user.id
              }
            })
          ); 
        });
      }
    } 
  }).select2('val', []);
});

/* getPath
 * @params - model (string)
 * Returns the user or repo bath, based on whether the string passed in is 'repo' or 'user'.
 */
function getPath (model) {
  if (model == 'user') {
    return $("#brand").attr('data-user-path');
  } else if (model == 'repo') {
    return $("#brand").attr('data-repo-path');
  } else if (model == 'team')
    return $("#brand").attr('data-team-path');
};
