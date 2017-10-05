// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require tether
//= require jquery_ujs
//= require cocoon
//= require bootstrap
//= require moment
//= require moment/ru
//= require bootstrap-datetimepicker
//= require typeahead
//= require material.min.js
//= require material-kit.js
//= require autocomplete
//= require bootstrap-colorpicker
//= require tags
//= require cocoon
//= require ckeditor/init
//= require chartkick
//= require_tree .


String.prototype.replaceAll = function(search, replacement) {
  var target = this;
  return target.split(search).join(replacement);
};

// Chartkick.configure({language: "ru-Ru"});
// Chartkick.charts.load('current', {'packages':['corechart'], 'language': 'ru'});
// var chart = Chartkick.charts["chart-id"]
// chart.setOptions({language: "ru"})