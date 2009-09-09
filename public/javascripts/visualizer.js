var Visualizer = function(canvas){
  var self = this;
  this.canvas = canvas;
  this.years = [];
  this.authors = [];
  this.colors = ["#ffa500","#90EE90"];
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

      this.drawGraph();
      
  },
  drawGraph: function(){
    
    for(i=0;i<=11;i++){
    
      this.page.text(i*40+20,350,i+1);
      //this.page.path(i*40+20,100).attr({stroke: "#ccc", opacity: .5}).lineTo(i*40+20,350);
      this.page.path("M"+(i*40+20)+" 100L"+(i*40+20)+" 350").attr({stroke: "#ccc", opacity: .5}) 
    
    }
    for(i=24;i>-0;i--){

      this.page.text(5,i*10+100,i);
      //this.page.path(5,i*10+100).attr({stroke: "#ccc", opacity: .5}).lineTo(40*12,i*10+100);
      this.page.path("M5 "+(i*10+100)+"L"+(40*12)+" "+(i*10+100)).attr({stroke: "#ccc", opacity: .5}) 
    
    }
    
  },
  drawNode: function(commit){
    var self = this;
    //self.checkCommitter(commit.author_email);
    var x = commit.committed_at.getMonth()*40+20;
    var y = (commit.committed_at.getHours()*10)+100+(commit.committed_at.getMinutes()/10);
    if (commit.line_total < 40){
      var s = commit.line_total;
    }else{
      var s = 40;
    }
    var c = this.page.circle(x,y,s);
    c.attr("stroke","#ffa500");
    c.attr("fill","#ffa500");
    c.attr("fill-opacity",".2");
    c.attr("opacity",.5);
    var d = this.page.circle(x,y,1);
    d.attr("stroke","#999");
    d.attr("fill","#999");
    d.attr("opacity",1);
    c.node.onclick = function(){
      var text = self.page.text(x,y,
      "message: "+
      commit.message+"\nline total: "+commit.line_total+"\nhour: "+commit.committed_at.getHours());
      setTimeout(function(){text.hide()},3000);
    }
  },
  checkCommitter: function(email){
    check = $.grep(this.authors,function(a){
      return a == email;
    });
    if(check.length == 0){
      this.authors.push({email: {email: this.colors[this.authors.length]}})
    }

  }
}
