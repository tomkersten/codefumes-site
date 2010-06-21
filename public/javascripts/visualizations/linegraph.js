function Linegraph(id, url) {
  this.url = url;
  this.id = id;
}

Linegraph.prototype = {
  requestAttributeData: function() {
    var self = this;
    $.getJSON(this.url, function(data) {
      self.responseHandler(data);
    });
  },
  
  responseHandler: function(data) {
    var values = this.collectValues(data);
    var count = this.countValues(values);
    this.renderGraph(values, count);
  },
  
  collectValues: function(data) {
    var values = [];
    
    $.each(data, function(index, commit) {
      attributeValue = parseInt(commit["commit_attribute"].value, 10);
      if(!isNaN(attributeValue)) {
        values.push(attributeValue);
      }
    });
    
    if(values.length > 20) {
      var length = values.length;
      values = values.slice(length - 20, length);
    }
    
    return values;
  },
  
  countValues: function(values) {
    if(values.length > 20) {
      return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];
    }
    
    var count = [];
    $.each(values, function(index) {
      count.push(index);
    });
    
    return count;
  },
  
  hasEnoughUniqueValues: function(values) {
    if(values.unique().length >= 2) {
      return true
    }
  },
  
  renderGraph: function(values, count) {
    if(this.hasEnoughUniqueValues(values)) {
      this.createRaphaelGraph(values, count);
    } else {
      this.createVisualizationError("Need more unique values to render graph");
    }
  },
  
  createVisualizationError: function(message) {
    new VisualizationError(message, this.id).buildAndInsert();
  },
  
  createRaphaelGraph: function(values, count) {
    gRaphael = Raphael('canvas');
    gRaphael.g.linechart(30, 20, 900, 400, count, values, {
      shade: true,
      nostroke: false, 
      axis: "0 0 0 1",
      symbol: 'o'
    });    
  }
};