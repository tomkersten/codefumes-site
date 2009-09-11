$(function(){
  $('ul.commits li ul').css("display", "none")
  $('ul.commits li h2').hover(
  function(){
    $(this).css({'cursor' : 'hand'});
  },
  function(){
    $(this).css({'cursor' : 'pointer'});
  }
  );
  $('ul.commits li h2').toggle(
  function(){
    $(this).parent().find('ul').slideDown('fast');
  },
  function(){
    $(this).parent().find('ul').slideUp('fast');
  }
  );
});

