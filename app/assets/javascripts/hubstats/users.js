// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  queryParameters = getUrlVars();
  setUserDefaults(queryParameters);

  $("#pulls").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#comments").on("click", function(){
    console.log($(this).attr('class'));
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#additions").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#deletions").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });
});

function toggleOrder(queryParams, sort_by) {
  console.log(queryParameters["order"]);
  if (queryParameters["order"] !== undefined) {
    if (queryParameters["order"] === sort_by+"-desc" ) {
      updateQueryStringParameter(queryParameters,"order",sort_by+"-asc");
    } else {
      updateQueryStringParameter(queryParameters,"order",sort_by+"-desc");
    }
  } else {
    updateQueryStringParameter(queryParameters,"order",sort_by+"-asc");
  }
}

function setUserDefaults(queryParameters) {
  if (queryParameters["order"]) {
    sort_by = queryParameters["order"].split("-")[0];
    order = queryParameters["order"].split("-")[1];
    if (order === 'asc') {
      $('#'+sort_by+' .octicon').addClass('octicon-arrow-up');
    } else {
      $('#'+sort_by+' .octicon').addClass('octicon-arrow-down');
    }
  }
  else {
    $("#pulls .octicon").addClass('octicon-arrow-down');
  }
}