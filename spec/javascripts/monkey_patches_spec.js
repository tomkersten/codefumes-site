describe("Array", function() {
  describe("#unique", function() {
    it("returns only the unique items in an array", function() {
      expect([4, 5, 5].unique()).toEqual(['4', '5']);
    });
  });
});