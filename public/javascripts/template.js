var MyVisual = function(canvas){
  var self = this;

  //create a 500x300px raphael svg on the canvas div.
  this.svg = Raphael(document.getElementById(canvas), 500, 300);
  //grab our json object from the server
  $.getJSON(
    document.location.href+".js",
    function(data){
      //now that we got it do stuff.
      self.parseData(data);
    }
  );

}

MyVisual.prototype = {
  parseData: function(data){
    
    var self = this;
    
    //cycle through each commit in the object.
    $(data.project.commits).each(
      function(){
        self.createDate(this);
        self.drawPoint(this);
      }
    );
    
  },
  createDate: function(commit){
      
      d = commit.committed_at.split("T");
      cal = d[0].split('-');
      var theDate = new Date(cal[0]+"/"+cal[1]+"/"+cal[2]+" "+d[1].replace("Z",""));
      commit.committed_at = theDate;

  },
  drawPoint: function(commit){
    var x = commit.committed_at.getMonth()*40+20;
    var y = (commit.committed_at.getHours()*10)+100+(commit.committed_at.getMinutes()/10);
    
    var c = this.svg.circle(x,y,10);
    c.attr("stroke","#ffa500");
    c.attr("fill","#ffa500");
    c.attr("fill-opacity",".2");
    c.attr("opacity",.5);
  }
}
