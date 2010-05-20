$(function(){

  $('ul.commits li ul').css('display', 'none');

  $('.hide-grandparent').click(function(event) {
      event.preventDefault();
      $(this).parent().parent().slideToggle("0.5");
    }
  );

  $('ul.commits li h2').hover(
  function(){
    $(this).css({'cursor' : 'hand'});
  },
  function(){
    $(this).css({'cursor' : 'pointer'});
  });

  $('ul.commits li h2').toggle(
  function(){
    $(this).parent().find('ul').slideToggle('fast');
  },
  function(){
    $(this).parent().find('ul').slideToggle('fast');
  });

});
