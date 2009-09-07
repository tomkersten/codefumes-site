var Visualizer = function(canvas){
  var self = this;
  this.canvas = canvas;
  this.years = [];
  $.getJSON(
    document.location.href+".js",
    function(data){
      self.parseData(data);
    }
  );

}

Visualizer.prototype = {
  parseData: function(data){
    var self = this;
    var tmpYear = "";
    pageHeight = 400;
    this.page = Raphael(document.getElementById(this.canvas), data.project.commits.length*50, pageHeight);
    var line = this.page.path({stroke: "#ffa500", "stroke-opacity": 1,"stroke-width": 10, "stroke-linecap": "round","stroke-linejoin": "round"}).moveTo(40, 100);
    
    $(data.project.commits).each(  
      function(){
        d = this.committed_at.split("T");
        cal = d[0].split('-')
        var theDate = new Date(cal[0]+"/"+cal[1]+"/"+cal[2]+" "+d[1].replace("Z",""));
        this.committed_at = theDate;
        if (this.committed_at.getYear() != tmpYear){
          tmpYear = this.committed_at.getYear();
          self.years.push(tmpYear);
        }
            
        self.drawNode(this);
      
      });
      console.log(self.years)
      this.drawGraph();
      
  },
  drawGraph: function(){
    
    for(i=0;i<=11;i++){
    
      this.page.text(i*40,350,i+1);
      this.page.path({stroke: "#ccc", opacity: .5}).moveTo(i*40,100).lineTo(i*40,350);   
    }
    for(i=24;i>-0;i--){

      this.page.text(5,i*10+100,i);
      this.page.path({stroke: "#ccc", opacity: .5}).moveTo(5,i*10+100).lineTo(40*12,i*10+100); 
    
    }
    
  },
  drawNode: function(commit){
    var x = commit.committed_at.getMonth()*40;
    var y = (commit.committed_at.getHours()*10)+100;
    if (commit.line_total < 100){
      var s = commit.line_total;
    }else{
      var s = 100;
    }
    var c = this.page.circle(x,y,s);
    c.attr("stroke","#333");
    c.attr("fill","#666");
    c.attr("fill-opacity",".2");
    c.attr("opacity",.5);
    var d = this.page.circle(x,y,1);
    d.attr("stroke","#999");
    d.attr("fill","#999");
    d.attr("opacity",1);
  }
}
