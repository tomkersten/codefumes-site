var MyVisual = function(canvas,url,options){

  this.options = $.extend({
      grid: {x:500/8, y:20},
      axis: {x:8, y:13},
      width: 500,
      height: 20*13
  }, options);
  
  var self = this;
  this.pathData = [];
  
  //create a grid svg on the canvas div.
  this.svg = new Grid(canvas,this.options);
  
  //grab our json object from the server
  $.getJSON(
    url,
    function(data){
      //now that we got it do stuff.
      self.parseData(data);
    }
  );

}

MyVisual.prototype = {
  parseData: function(data){
    
    var self = this;
//    cycle through each commit in the object.
//    var commits = $.grep(data.project.commits, function(c,i){
//      return (c.committed_at.getHours() < 18 && c.committed_at.getHours() > 5)
//    });
    $(data.project.commits).each(
      function(index){
        self.createDate(this);
        //console.log(this.committed_at.getDay());
          //if(this.committed_at.getHours() < 18 && this.committed_at.getHours() > 5){
          self.drawPoint(this,index);
          //}
      }
    );
  },
  createDate: function(commit){
      
      d = commit.committed_at.split("T");
      cal = d[0].split('-');
      var theDate = new Date(cal[0]+"/"+cal[1]+"/"+cal[2]+" "+d[1].replace("Z",""));
      commit.committed_at = theDate;

  },
  drawPoint: function(commit,index){
    var x = (commit.committed_at.getDay()+1)*this.options.grid.x;
    var y = (commit.committed_at.getHours()*this.options.grid.y)+(commit.committed_at.getMinutes()/3);
    if(index==0){
      this.pathData.push("M"+x+" "+y);
    }else{
      this.pathData.push("L"+x+" "+y);
    }
    var c = this.svg.circle(x,y,8);
    c.attr("stroke","#336699");
    c.attr("fill","#FFCC00");
    c.attr("fill-opacity",".5");
    c.attr("opacity",.5);
  },
  clear: function(){
    this.svg.remove();
  }
}
