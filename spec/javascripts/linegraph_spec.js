var responseWithStringValue = [
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T20:37:50Z","updated_at":"2010-06-13T20:37:50Z","commit_id":6,"id":2,"value":"50"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"the"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:17:25Z","updated_at":"2010-06-13T21:17:25Z","commit_id":10,"id":6,"value":"20"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:27:18Z","updated_at":"2010-06-13T21:27:18Z","commit_id":11,"id":8,"value":"20"}}
];

var response = [
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T20:37:50Z","updated_at":"2010-06-13T20:37:50Z","commit_id":6,"id":2,"value":"50"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"50"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:17:25Z","updated_at":"2010-06-13T21:17:25Z","commit_id":10,"id":6,"value":"20"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:27:18Z","updated_at":"2010-06-13T21:27:18Z","commit_id":11,"id":8,"value":"20"}}
];

var extendedResponse = [
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T20:37:50Z","updated_at":"2010-06-13T20:37:50Z","commit_id":6,"id":2,"value":"1"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"2"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:17:25Z","updated_at":"2010-06-13T21:17:25Z","commit_id":10,"id":6,"value":"3"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T20:37:50Z","updated_at":"2010-06-13T20:37:50Z","commit_id":6,"id":2,"value":"4"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"5"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:17:25Z","updated_at":"2010-06-13T21:17:25Z","commit_id":10,"id":6,"value":"6"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T20:37:50Z","updated_at":"2010-06-13T20:37:50Z","commit_id":6,"id":2,"value":"7"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"8"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:17:25Z","updated_at":"2010-06-13T21:17:25Z","commit_id":10,"id":6,"value":"9"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T20:37:50Z","updated_at":"2010-06-13T20:37:50Z","commit_id":6,"id":2,"value":"10"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"11"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:17:25Z","updated_at":"2010-06-13T21:17:25Z","commit_id":10,"id":6,"value":"12"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T20:37:50Z","updated_at":"2010-06-13T20:37:50Z","commit_id":6,"id":2,"value":"13"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"14"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:17:25Z","updated_at":"2010-06-13T21:17:25Z","commit_id":10,"id":6,"value":"15"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T20:37:50Z","updated_at":"2010-06-13T20:37:50Z","commit_id":6,"id":2,"value":"16"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"17"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:17:25Z","updated_at":"2010-06-13T21:17:25Z","commit_id":10,"id":6,"value":"18"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T20:37:50Z","updated_at":"2010-06-13T20:37:50Z","commit_id":6,"id":2,"value":"19"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"20"}},
  {"commit_attribute":{"name":"chairs","created_at":"2010-06-13T21:16:04Z","updated_at":"2010-06-13T21:16:04Z","commit_id":9,"id":4,"value":"21"}}
];



describe("Linegraph", function(){
  
  var linegraph,
      url = window.location + ".js",
      id = 'canvas';
  
  beforeEach(function() {
    linegraph = new Linegraph(id, url);
  });
  
  describe("#initializing", function() {
    it("stores canvas id", function() {
      expect(linegraph.id).toEqual(id);
    });

    it("stores json request url", function() {
      expect(linegraph.url).toEqual(url);
    });
  });
  
  describe("#requestAttributeData", function() {
    it("calls to getJSON to load Attribute JSON data", function() {
      spyOn($, 'getJSON');
      linegraph.requestAttributeData();
      expect($.getJSON).wasCalled();
    });
  });
  
  describe("#collectValues", function() {
    it("returns an array of values extracted from the JSON response", function() {
      expect(linegraph.collectValues(response)).toEqual([50, 50, 20, 20]);
    });
  
    it("returns an array of values that does not contain any strings extracted from the JSON response", function() {
      expect(linegraph.collectValues(responseWithStringValue)).toEqual([50, 20, 20]);
    });
    
    it("returns the most recent 20 values if there are more than is more than 20", function() {
      expect(linegraph.collectValues(extendedResponse)).toEqual([2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]);
    })
  });
  
  describe("#countValues", function() {
    it("returns a array counting to 4 with there are 4 values to graph", function() {
      expect(linegraph.countValues([50, 50, 20, 20])).toEqual([0, 1, 2, 3]);  
    });
    
    it("returns a array counting to 3 with there are 3 values to graph", function() {
      expect(linegraph.countValues([50, 50, 20])).toEqual([0, 1, 2]);  
    });
    
    it("returns a max of 20 numbers", function() {
      var values = [50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20];
      expect(linegraph.countValues(values).length).toEqual(20);
    });
  });
  
  describe("#hasEnoughUniqueValues", function() {
    it("return true when there are at least 2 unique values to graph", function() {
      expect(linegraph.hasEnoughUniqueValues([30, 40])).toBeTruthy();
    });
    
    it("return false when there are not at least 2 unique values to graph", function() {
      expect(linegraph.hasEnoughUniqueValues([40, 40])).toBeFalsy();
    });
    
    it("return false when there are less than 2 values to graph", function() {
      expect(linegraph.hasEnoughUniqueValues([40])).toBeFalsy();
    });
  });
  
  describe("#renderGraph", function() {
    it("renders graph when value requirements are met", function() {
      spyOn(linegraph, 'createRaphaelGraph');
      linegraph.renderGraph([40,50]);
      expect(linegraph.createRaphaelGraph).wasCalled();
    });
    
    it("creates a visualization error when requirements are not met", function() {
      spyOn(linegraph, 'createVisualizationError');
      linegraph.renderGraph([40]);
      expect(linegraph.createVisualizationError).wasCalled();
    })
  });
});