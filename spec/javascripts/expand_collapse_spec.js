describe("ExpandCollapse", function() {
  var id = 'id',
      expandCollapse;
  
  beforeEach(function() {
    expandCollapse = new ExpandCollapse(id);
  });
  
  describe("#initializing", function() {
    it("stores the parent container", function() {
      expect(expandCollapse.id).toEqual(id);
    });

    it("finds and stores the handle", function() {
      expect(expandCollapse.handle).toBeDefined();
    });

    it("finds and stores the container", function() {
      expect(expandCollapse.container).toBeDefined();
    });
  });
  
  describe("#attachBehavior", function() {
    it("attaches a click to the handle", function() {
      spyOn($.fn, 'click');
      expandCollapse.attachBehavior();
      expect($.fn.click).wasCalled();
    });
  });
  
  describe("#toggleVisiblity", function() {
    it("toggles the visibility of the container", function() {
      spyOn($.fn, 'slideToggle');
      expandCollapse.toggleVisibility();
      expect($.fn.slideToggle).wasCalled();
    });
  });
});