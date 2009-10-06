$(function(){

  $('input').focus(function(){
    $(this).parent().prev('div').addClass('focus');
  });

  $('input').blur(function(){
    $(this).parent().prev('div').removeClass('focus');
  });
  
});