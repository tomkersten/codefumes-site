require("spec_helper.js");
require("../../public/javascripts/initializer.js");

Screw.Unit(function(){

  describe("Initializer", function(){

    it("should not initially show the contents of list item", function(){

      $("ul.commits li ul").each(function(){
        expect($(this).is(':visible')).to(equal, false);
      });
    
    });

    it("should expand contents of list items when respective header is clicked", function(){

      $('ul.commits li h2').each(function(){
        $(this).trigger('click');
      });

      $("ul.commits li ul").each(function(){
        expect($(this).is(':visible')).to(equal, true);
      });
  
    });
  
  });

});