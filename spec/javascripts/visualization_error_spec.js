describe("VisualizationError", function() {
  var message = "This is the error message",
      graphId = 'canvas',
      assembledMessage = '<h3>' + message + '</h3>',
      visualizationError;
  
  beforeEach(function() {
    visualizationError = new VisualizationError(message, graphId);
  });
  
  describe("#initializing", function() {
    it("stores an error message", function() {
      expect(visualizationError.message).toEqual(message);
    });
    
    it("stores a graph id", function() {
      expect(visualizationError.id).toEqual(graphId);
    });
  });
  
  describe("#build", function() {
    it("returns the message wrapped in html", function() {
      expect(visualizationError.build()).toEqual(assembledMessage)
    });
  });
  
  describe("#insert", function() {
    it("inserts an html string into the graph id that was initially passed", function() {
      spyOn($.fn, 'append');
      visualizationError.insert(assembledMessage);
      expect($.fn.append).wasCalledWith(assembledMessage);
    });
    
    it("added a class of error to the parent", function() {
      spyOn($.fn, 'addClass');
      visualizationError.insert(assembledMessage);
      expect($.fn.addClass).wasCalledWith('visualization_error');
    });
  });
  
  describe("#buildAndInsert", function() {
    it("calls build", function() {
      spyOn(visualizationError, 'build');
      visualizationError.buildAndInsert();
      expect(visualizationError.build).wasCalled();
    });
    
    it("calls insert", function() {
      spyOn(visualizationError, 'insert');
      visualizationError.buildAndInsert();
      expect(visualizationError.insert).wasCalledWith(assembledMessage);
    });
  });
});