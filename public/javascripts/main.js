var CommitsOverTime = function(canvas,url,options){

  this.options = $.extend({
      grid: {x:950/8, y:12},
      axis: {x:8, y:25},
      width: 950,
      height: (12*25)+10,
      offset: {l:30,t:20,b:20},
      opacity: '.5'
  }, options);
  var self = this;
  this.pathData = [];
  
  //create a grid svg on the canvas div.
  this.svg = new Grid(canvas,this.options);
  this.circle = this.svg.circle(0,0,8).attr({"stroke":"none","fill":"#ACD373","fill-opacity":.5}).hide();

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
          if(index == 4 || index == 9 || index == 11){
            this.build_outcome="failed"
          }
          
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
    var x = ((commit.committed_at.getDay()+1)*this.options.grid.x)+this.options.offset.l;
    var y = ((commit.committed_at.getUTCHours())*this.options.grid.y)+(commit.committed_at.getMinutes()/3)+this.options.offset.t;
    //console.log(commit.committed_at.getHours());
    
    if(index==0){
      this.pathData.push("M"+x+" "+y);
    }else{
      this.pathData.push("L"+x+" "+y);
    }
    if(x<this.options.width&&y<this.options.height){
      //var c = this.circle.clone(this.svg,x,y);
      var c = this.circle.cloneN(this.svg,x,y);
      c.setAttribute("cx",x);
      c.setAttribute("cy",y);
      c.setAttribute("style","display:block;");
      if(commit.build_outcome=="failed"){
        c.setAttribute("fill","#ff0000");
      }
      c.onclick = function(){
        self.drawModal( x, y, commit);
      }
      
    }
  },
  drawLabels: function(){
    var self = this
    this.weekdays=["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    for(i=1;i<=24;i++){
      if(i==1 || i==6 || i==12 || i==18 || i == 24){
        if(i==24){text="END"}else{text=i}
        this.svg.text(0, (this.options.grid.y*i)+this.options.offset.t, text).attr({"text-anchor":"start", "stroke":"#ACD373"});
      }
    }
    $(this.weekdays).each(
      function(d,day){
        self.svg.text((self.options.grid.x*d)+(self.options.offset.l+self.options.grid.x),self.options.height+self.options.offset.b-5, day).attr({ "stroke":"#ACD373"});
      }
    );
    this.svg.path("M{2} {3}L{2} {0}L{1} {0}L{1} {3}L{2} {3}",this.options.height-(this.options.grid.y*6),this.options.width,this.options.offset.l,this.options.offset.t+(this.options.grid.y*5)).attr({fill: "#556677",'fill-opacity':this.options.opacity,stroke:'none'}).toBack();
  },
  drawModal: function(x,y,commit){
    //this.clearModal(); 
    /*
    if(this.modal == undefined){
      this.modal = new SvgModal();
    }else{
      this.modal.moveTo(x,y)
    }
   */
    if(this.modal == undefined){
      this.modal = this.svg.path("M{0} {1}L{2} {3}V{7}H{4}V{5}H{2}V{6}",x,y,x+20,y-15,x+170,y+75,y+5,y-25).attr({fill: "#ACD373",'fill-opacity':.75,stroke:'#00AEEF'});
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
