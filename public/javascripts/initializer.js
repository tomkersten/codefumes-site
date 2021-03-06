$(document).ready(function() {
  var jsonUrl = window.location + '.js';
  
  $('.js_linegraph').each(function() {
    new Linegraph(this, jsonUrl).requestAttributeData();
  });
  
  $('.js_build_status').each(function() {
    new CommitsOverTime('canvas', jsonUrl, {});
  });
  
  $('.js_expand_collapse').each(function() {
    new ExpandCollapse(this).attachBehavior();
  });
});