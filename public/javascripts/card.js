var Card = function(canvas){

  var self = this;

  this.canvas = Raphael(canvas, 500, 300);

  $.getJSON(
    document.location.href+".js",
    function(data){
      //now that we got it do stuff.
      self.parseData(data);
    }
  );

}

Card.prototype = {

  parseData: function(data){
    var that = this;
    $(data.project.commits).each(
      function(){
        that.drawCard();
      }
    );
    
  },

  drawCard: function(){
    console.log(this)
    var t = this.canvas.text(200, 100, "text message rendered to page");
  }
}
