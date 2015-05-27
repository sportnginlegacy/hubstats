$(document).ready(function() {
  queryParameters = getUrlVars();
  setDefaults(queryParameters);
  initLabels(queryParameters)
  changeColors();

  $("#state-group > .btn").on("click", function(){
    updateQueryStringParameter(queryParameters,"state",$(this).attr('id'));
  });

  $("#sort-group > .btn").on("click", function(){
    updateQueryStringParameter(queryParameters,"order",$(this).attr('id'));
  });

  $("#group-by").on("change", function(){
    updateQueryStringParameter(queryParameters,"group",$(this)[0].value);
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
