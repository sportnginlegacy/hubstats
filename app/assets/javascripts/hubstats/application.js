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
  $('.input-daterange').datepicker({
    "todayHighlight": true,
    "endDate": "Today",
    "todayBtn": true
  });
  setDateRange()
});

function setDateRange() {
  var dates;
  var timer;
  var datesArray = [];

  if ((readCookie("hubstats_dates") === "null~~null") || (readCookie("hubstats_dates") === null)) {
    dates = getDefaultDateRange();
  } else {
    dates = readCookie("hubstats_dates")
  }

  timer = document.getElementById("submitDateRange");
  datesArray = dates.split("~~")

  $('.input-daterange').find('[name="start"]').datepicker('update', new Date(datesArray[0]));
  $('.input-daterange').find('[name="end"]').datepicker('update', new Date(datesArray[1]));

  timer.onclick = function() {
    var start_date;
    var end_date;
    var date;
    start_date = $('.input-daterange').find('[name="start"]').datepicker('getDate');
    end_date = $('.input-daterange').find('[name="end"]').datepicker('getDate');
    
    date = new Date();
    date.setTime(date.getTime()+(24*60*60*1000));
    var expires = "; expires="+date.toGMTString();
    createCookie("hubstats_dates=" + start_date + "~~" + end_date + expires + "; path=/");
    window.location.reload();
  };
};

function createCookie(str) {
  document.cookie = str;
};

function readCookie(name) {
  var cookieName = name + "=";
  var cookieData = document.cookie.split(';');
  for(var i=0;i < cookieData.length;i++) {
    var c = cookieData[i];
    while (c.charAt(0)==' ') c = c.substring(1,c.length);
    if (c.indexOf(cookieName) == 0) return c.substring(cookieName.length,c.length);
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
