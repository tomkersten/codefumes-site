require("spec_helper.js");
require("../../public/javascripts/initializer.js");

Screw.Unit(function(){
  describe("Initializer", function(){
    it("should expand contents of list item when header is clicked", function(){
      expect($("ul#commits li ul").css("display")).to(equal,"block");
    });
  });
});
