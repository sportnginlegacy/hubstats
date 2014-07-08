// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  queryParameters = getUrlVars();
  setDefaults(queryParameters);

  $("#state-group > .btn").on("click", function(){
    updateQueryStringParameter(queryParameters,"state",$(this).attr('id'));
  });

  $("#repos").change(function() {
    var ids = $("#repos").val();
    updateQueryStringParameter(queryParameters,"repo",ids);
  });

  $("#sort-group > .btn").on("click", function(){
    updateQueryStringParameter(queryParameters,"order",$(this).attr('id'));
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
    uri = (uri + separator + value + '=' + queryParameters[value]);
  }

  document.location.href = uri
}

function getUrlVars() {
    var vars = [], hash;
    if (window.location.href.indexOf('?') > 0) {
      var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');

      for(var i = 0; i < hashes.length; i++)
      {
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
    $('#asc').addClass('active');
}



$(document).ready(function() { 
  $("#repos").select2({
    data:[
      {id:126422,text:"Ngin"},
      {id:16285416,text:"Soyus"},
      {id:20231003,text:"Hubstats"},
    ],
    placeholder: "Repositories",
    multiple: true
  }); 
  $("#users").select2({
    placeholder: "Users"
  }); 
});