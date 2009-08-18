$(function(){
  $('ul.commits li ul').css("display","none")
  $('ul.commits li h2').toggle(
  function(){
    $(this).parent().find('ul').show();
  },
  function(){
    $(this).parent().find('ul').hide();
  }
  );
});

