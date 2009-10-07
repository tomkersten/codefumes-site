var CommitsOverTime = function(canvas,url,options){

  this.options = $.extend({
      grid: {x:500/8, y:10},
      axis: {x:8, y:25},
      width: 500,
      height: (10*25)+10,
      offset: {r:30,t:20},
      opacity: '.5'
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
  this.drawLabels();
}

CommitsOverTime.prototype = {
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
  var self = this;
    var x = (commit.committed_at.getDay()+1)*this.options.grid.x;
    var y = (commit.committed_at.getHours()*this.options.grid.y)+(commit.committed_at.getMinutes()/3);
    //console.log(commit.committed_at.getHours());
    
    if(index==0){
      this.pathData.push("M"+x+" "+y);
    }else{
      this.pathData.push("L"+x+" "+y);
    }
    var c = this.svg.circle(x,y,8);
    c.attr("stroke","none");
    c.attr("fill","#ACD373");
    c.attr("fill-opacity",".5");
    //c.attr("opacity",.5);
    c.node.onclick = function(){
      self.drawModal( x, y, commit);
    }
  },
  drawLabels: function(){
    for(i=1;i<24;i++){
      if(i>5 && i < 18){
        this.svg.text(0, (this.options.grid.y*i)+this.options.offset.t, i+":00").attr({"text-anchor":"start", "stroke":"#FFF"});
      }
      else if(i<=5 || i >= 18){
        this.svg.text(0, (this.options.grid.y*i)+this.options.offset.t, i+":00").attr({"text-anchor":"start", "stroke":"#999"});
      }
    }
    this.svg.path("M{2} {3}L{2} {0}L{1} {0}L{1} {3}L{2} {3}",this.options.height-(this.options.grid.y*6),this.options.width,this.options.offset.r,this.options.offset.t+(this.options.grid.y*5)).attr({fill: "#556677",'fill-opacity':this.options.opacity,stroke:'none'}).toBack();
  },
  drawModal: function(x,y,commit){
    //this.clearModal();
    if(this.modal == undefined){
      this.modal = this.svg.path("M{0} {1}L{2} {3}V{7}H{4}V{5}H{2}V{6}",x,y,x+20,y-15,x+170,y+75,y+5,y-25).attr({fill: "#FFF",'fill-opacity':this.options.opacity,stroke:'#ACD373'});
    }else{
      this.modal.animate({"path": "M"+x+" "+y+"L"+(x+20)+" "+(y-15)+"V"+(y-25)+"H"+(x+170)+"V"+(y+75)+"H"+(x+20)+"V"+(y+5)},1000, "bounce")
    }
    /*
    this.copy = this.svg.text(x+30,y,
      "message: "+
      commit.message+"\nline total: "+commit.line_total+"\nhour: "+commit.committed_at.getHours()
    ).attr({"text-anchor":"start","width":150});
    */
  },
  clearModal: function(){
    if(this.copy != undefined){
      this.copy.remove();
    }
  },
  clear: function(){
    this.svg.remove();
  }
}
