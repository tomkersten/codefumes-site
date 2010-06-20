function VisualizationError(message, id) {
  this.message = message;
  this.id = id;
}

VisualizationError.prototype = {
  build: function() {
    // TODO: get string HTML the heck out of here.
    return '<h3>' + this.message + '</h3>';
  },
  
  insert: function(message) {
    $(this.id).append(message);
    $(this.id).addClass('visualization_error');
  },
  
  buildAndInsert: function() {
    var assembledMessage = this.build();
    this.insert(assembledMessage);
  }
}