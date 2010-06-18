require("spec_helper.js");
require("fixtures/linegraph_responses.js");
require("../../public/javascripts/graphs/linegraph.js");
require("../../public/javascripts/frameworks/array.js");

// TODO: Better place for this?
function Raphael() { }
Raphael.prototype = {
  g: {
    linegraph: function() {
      
    }
  }
}

Screw.Unit(function(){
  describe("Linegraph", function(){
    
    var linegraph,
        url = window.location + ".js",
        id = 'canvas';
    
    before(function() {
      linegraph = new Linegraph(id, url);
    });
    
    describe("#initializing", function() {
      it("stores canvas id", function() {
        expect(linegraph.id).to(equal, id);
      });

      it("stores json request url", function() {
        expect(linegraph.url).to(equal, url);
      });
    });
    
    describe("#requestAttributeData", function() {
      it("calls to getJSON to load Attribute JSON data", function() {
        mock($).should_receive("getJSON").with_arguments(linegraph.url, linegraph.responseHandler).exactly('once');
        linegraph.requestAttributeData();
      });
    });
    
    describe("#responseHandler", function() {
      it("calls collectValues with JSON call response", function() {
        mock(linegraph).should_receive("collectValues").with_arguments(response).exactly('once');
        linegraph.stub('renderGraph');
        linegraph.stub('countValues');
        linegraph.responseHandler(response);
      });
      
      it("calls countValues with graph values", function() {
        mock(linegraph).should_receive("countValues").with_arguments([50, 50, 20, 20]).exactly('once');
        linegraph.stub('renderGraph');
        linegraph.responseHandler(response);
      });
      
      it("calls renderGraph with collected values and counted values", function() {
        mock(linegraph).should_receive("renderGraph").with_arguments([50, 50, 20, 20], [0, 1, 2, 3]).exactly('once');
        linegraph.responseHandler(response);
      });
    });
    
    describe("#collectValues", function() {
      it("returns an array of values extracted from the JSON response", function() {
        expect(linegraph.collectValues(response)).to(equal, [50, 50, 20, 20]);
      });

      it("returns an array of values that does not contain any strings extracted from the JSON response", function() {
        expect(linegraph.collectValues(responseWithStringValue)).to(equal, [50, 20, 20]);
      });
      
      it("returns the most recent 20 values if there are more than is more than 20", function() {
        expect(linegraph.collectValues(extendedResponse)).to(equal, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]);
      })
    });
    
    describe("countValues", function() {
      it("returns a array counting to 4 with there are 4 values to graph", function() {
        var result = linegraph.countValues([50, 50, 20, 20]);
        expect(result).to(equal, [0, 1, 2, 3]);  
      });
      
      it("returns a array counting to 3 with there are 3 values to graph", function() {
        var result = linegraph.countValues([50, 50, 20]);
        expect(result).to(equal, [0, 1, 2]);  
      });
      
      it("returns a max of 20 numbers", function() {
        var result = linegraph.countValues([50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20, 50, 50, 20, 20]);
        expect(result.length).to(equal, 20);
      });
      
    });
    
    describe("#hasEnoughUniqueValues", function() {
      it("return true when there are at least 2 unique values to graph", function() {
        var result = linegraph.hasEnoughUniqueValues([30, 40]);
        expect(result).to(be_true);
      });
      
      it("return false when there are not at least 2 unique values to graph", function() {
        var result = linegraph.hasEnoughUniqueValues([40, 40]);
        expect(result).to(be_false);
      });
      
      it("return false when there are less than 2 values to graph", function() {
        var result = linegraph.hasEnoughUniqueValues([40]);
        expect(result).to(be_false);
      });
    });
  });
});