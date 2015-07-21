// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

/* This function is run whenever the Metrics page or the Users page is opened or refreshed. It will
 * sort all of the repos/users sorted by count of (or alphabetically by) name, number of deploys,
 * number of merged pull requests, number of comments, net additions, average additions, or average
 * deletions.
 */
$(document).ready(function() {
  queryParameters = getUrlVars();
  setUserDefaults(queryParameters);

  $("#name").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#deploys").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#pulls").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#comments").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#netadditions").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#additions").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#deletions").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#pulls_per_dev").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });

  $("#comments_per_rev").on("click", function(){
    toggleOrder(queryParameters,$(this).attr('id'));
  });
});

/* toggleOrder
 * @params - queryParams, sort_by
 * Will toggle the order that the data is sorted by (highest first or lowest first).
 */
function toggleOrder(queryParams, sort_by) {
  if (queryParams["order"] !== undefined) {
    if (queryParams["order"] === sort_by+"-desc" ) {
      updateQueryStringParameter(queryParams,"order",sort_by+"-asc");
    } else {
      updateQueryStringParameter(queryParams,"order",sort_by+"-desc");
    }
  } else {
    updateQueryStringParameter(queryParams,"order",sort_by+"-asc");
  }
}

/* setUserDefaults
 * @params - queryParameters
 * Sets the arrow next to what piece of data is being sorted.
 */
function setUserDefaults(queryParams) {
  if (queryParams["order"]) {
    sort_by = queryParams["order"].split("-")[0];
    order = queryParams["order"].split("-")[1];
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
