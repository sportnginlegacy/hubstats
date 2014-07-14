// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  queryParameters = getUrlVars();
  setUserDefaults(queryParameters);

  $("#user-sort-group > .btn").on("click", function(){
    updateQueryStringParameter(queryParameters,"order",$(this).attr('id'));
  });

});

function setUserDefaults(queryParameters) {
  if (queryParameters["order"])
    $('#' + queryParameters["order"]).addClass('active');
  else 
    $('#smallest-pulls').addClass('active');
}