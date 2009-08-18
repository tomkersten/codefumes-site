$(function(){
  $('ul.commits li ul').css("display","none")
  $('ul.commits').toggle(
  function(){
    $(this).find('li ul').show();
  },
  function(){
    $(this).find('li ul').hide();
  }
  );
});

