// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  queryParameters = getUrlVars();
  setDefaults(queryParameters);
  checkedLabels(queryParameters);
  initLabels(queryParameters)
  changeColors();

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

function checkedLabels () {
  $(".checkbox :checkbox").change(function(e){
    var labels = '';
    var checked = $(":checkbox:checked");
    for (var i = 0; i < checked.length; i++) {
      var separator = (i == 0 ? '' : ',');
      labels = labels + separator + checked[i].value;
    }
    updateQueryStringParameter(queryParameters,"label",labels);
  });
}

function initLabels (queryParameters) {
  if (queryParameters["label"]) {
    var labels = queryParameters["label"].replace('%20',' ').split(',');

    $(":checkbox").each( function() {
      if ($.inArray( $(this)[0].value , labels ) >= 0) 
        $(this).prop("checked", true);
    });
  }
}

function changeColors () {
  $(".color-label").each( function() {
    var color = '#' + $(this)[0].title;

    $(this).css('background-color',color)
  })

}