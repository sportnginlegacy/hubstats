// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require select2
//= require hubstats/bootstrap
//= require bootstrap-datepicker
//= require_tree .

$(document).ready( function() {
  defaultDateRange()
  setDateRange()
});

function defaultDateRange() {
  $('.input-daterange').datepicker({
    "todayHighlight": true,
    "endDate": "Today",
    "todayBtn": true
  });
};

function setDateRange() {
  if ((readCookie("hubstats_index") === "null~~null") || (readCookie("hubstats_index") === null)) {
    var index = getDefaultDateRange();
  } else {
    var index = readCookie("hubstats_index")
  }

  var timer = document.getElementById("submitDateRange");
  dates = index.split("~~")
  $('.input-daterange').find('[name="start"]').datepicker('update', new Date(dates[0]));
  $('.input-daterange').find('[name="end"]').datepicker('update', new Date(dates[1]));

  timer.onclick = function() {
    start_date = $('.input-daterange').find('[name="start"]').datepicker('getDate');
    end_date = $('.input-daterange').find('[name="end"]').datepicker('getDate');
    createCookie("hubstats_index", start_date, end_date, 1);
    window.location.reload();
  };
};

function createCookie(name,value1,value2,days) {
  if (days) {
    var date = new Date();
    date.setTime(date.getTime()+(days*24*60*60*1000));
    var expires = "; expires="+date.toGMTString();
  }
  else var expires = "";
  document.cookie = name+"="+value1+"~~"+value2+expires+"; path=/";
};

function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') c = c.substring(1,c.length);
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
  }
  return null;
};

function eraseCookie(name) {
    createCookie(name,"",-1);
};

function getDefaultDateRange() {
  var today = new Date();
  var dd = today.getDate();
  var mm = today.getMonth() + 1; //January is 0!
  var yyyy = today.getFullYear();

  if(dd < 10) {
    dd = '0' + dd
  } 

  if(mm < 10) {
    mm = '0' + mm
  } 

  today = mm + '/' + dd + '/' + yyyy;
  twoWeeksAgo = new Date(today);
  twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);
  return twoWeeksAgo + '~~' + today;
};
