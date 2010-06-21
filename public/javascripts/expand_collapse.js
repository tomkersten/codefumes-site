function ExpandCollapse(id) {
  this.id = id;
  this.handle = $(id).find('.js_handle');
  this.container = $(id).find('.js_container');
}

ExpandCollapse.prototype = {
  attachBehavior: function() {
    var self = this;
    $(this.handle).click(function() {
      self.toggleVisibility();
    });
  },
  
  toggleVisibility: function() {
    $(this.container).slideToggle();
  }
}