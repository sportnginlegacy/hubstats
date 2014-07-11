$(document).ready(function() { 
  usersIDs = queryParameters["users"] ? queryParameters["users"].replace("%2C", ",") : "";
  reposIDs = queryParameters["repos"] ? queryParameters["repos"].replace("%2C", ",") : "";

  $("#repos").select2({
    placeholder: "Repositories",
    multiple: true,
    ajax: {
      url: "./repos",
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
        $.ajax("./repos", {
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


  $("#users").select2({
    placeholder: "Users",
    multiple: true,
    ajax: {
      url: "./users",
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
        $.ajax("./users", {
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