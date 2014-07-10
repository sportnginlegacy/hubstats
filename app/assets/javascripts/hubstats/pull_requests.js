// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  queryParameters = getUrlVars();
  setDefaults(queryParameters);

  $("#state-group > .btn").on("click", function(){
    updateQueryStringParameter(queryParameters,"state",$(this).attr('id'));
  });

  $("#sort-group > .btn").on("click", function(){
    updateQueryStringParameter(queryParameters,"order",$(this).attr('id'));
  });

  $("#repos").change(function() {
    var ids = $("#repos").val();
    updateQueryStringParameter(queryParameters,"repos",ids);
  });
  
  $("#users").change(function() {
    var ids = $("#users").val();
    updateQueryStringParameter(queryParameters,"users",ids);
  });
});


function updateQueryStringParameter(queryParameters, key, value) {
  var uri = document.location.pathname;
  if (!queryParameters[key])
    queryParameters.push(key)
  queryParameters[key] = value;

  var i;
  for (i = 0; i < queryParameters.length; i++) {
    var separator = uri.indexOf('?') !== -1 ? "&" : "?";
    var value = queryParameters[i];
    if (queryParameters[value].length >= 1)
      uri = (uri + separator + value + '=' + queryParameters[value]);
  }

  document.location.href = uri
}

function getUrlVars() {
  var vars = [], hash;
  if (window.location.href.indexOf('?') > 0) {
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');

    for (var i = 0; i < hashes.length; i++) {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
  }

  return vars;
}

function setDefaults(queryParameters) {
  if (queryParameters["state"])
    $('#' + queryParameters["state"]).addClass('active');
  else 
    $('#all').addClass('active');

  if (queryParameters["order"])
    $('#' + queryParameters["order"]).addClass('active');
  else
    $('#desc').addClass('active');
}



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