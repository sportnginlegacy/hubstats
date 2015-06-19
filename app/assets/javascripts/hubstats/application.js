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
  setTimespan()
});

$(document).on("focus", "[data-behaviour~='datepicker']", function(e){
  $(this).datepicker({
    "format": "yyyy-mm-dd",
    "weekStart": 1,
    "autoclose": true,
    "todayHighlight": true})
});

function setTimespan() {
  var index = readCookie("hubstats_index") || 2;
  var timer = document.getElementById("time-select");

  timer.selectedIndex = index;

  timer.onchange = function() {

    createCookie("hubstats_index",this.selectedIndex,1);
    window.location.reload();
  };
};

function createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
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
