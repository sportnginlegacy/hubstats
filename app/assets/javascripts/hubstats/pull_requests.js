// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  queryParameters = getUrlVars();
  setDefaults(queryParameters);
  activeLabels(queryParameters);
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

function initLabels (queryParameters) {
  if (queryParameters["label"]) {
    var labels = queryParameters["label"].replace('%20',' ').split(',');

    $("#labels-container .btn-label").each( function() {
      var color = '#' + $(this).data("color");
      if ($.inArray( $(this).children().eq(1).data("label") , labels ) >= 0) {
        $(this).addClass("active");
        $(this).css('background-color',color);
        $(this).css("color", isDark($(this).css("background-color")) ? 'white' : 'black');
      }
    });
  }
}

function changeColors () {
  $(".color-label").each( function() {
    var color = '#' + $(this)[0].title;
    $(this).css('background-color',color)
    $(this).css("color", isDark($(this).css("background-color")) ? 'white' : 'black');
  });

  $("#labels-container .btn-label").each( function() {
    var color = '#' + $(this).data("color");
    $(this).children().eq(0).css('background-color',color);
  });

}

function activeLabels () {
  $("#labels-container .btn-label").click(function () {
    $(this).toggleClass("active");

    var labels = '';
    $("#labels-container").children().each( function() {
      if ($(this).hasClass('active')) {
        var separator = (labels.length == 0 ? '' : ',');
        labels = labels + separator + $(this).children().eq(1).data('label');
      }
    });
    updateQueryStringParameter(queryParameters,"label",labels);
  });
}

function isDark( color ) {
    var match = /rgb\((\d+).*?(\d+).*?(\d+)\)/.exec(color);
    return parseFloat(match[1])
         + parseFloat(match[2])
         + parseFloat(match[3])
           < 3 * 256 / 2;
}
