var Grid = function(canvas,options){

  this.options = $.extend({
      width: 500,
      height: 200,
      background: '#2F69BF',
      grid: {x:20, y:40},
      axis: {x:100, y:80},
      offset: {r:0,t:0,l:0,b:0}
  }, options);
  
  this.svg = Raphael(document.getElementById(canvas), this.options.width+1, this.options.height+1+this.options.offset.b);
  this.drawFrame();
  this.drawGrid(this.options.axis.x,this.options.axis.y);
  
  return this.svg;
  
}

Grid.prototype = {

  drawGrid: function(xAxis,yAxis){
  
    for (i=1;i < (yAxis+1);i++){
      var y = (i*this.options.grid.y)+this.options.offset.t;
      if(y<this.options.height)
        this.svg.path("M{2} {0}L{1} {0}",y,this.options.width,this.options.offset.l).attr({stroke:'#FFF',opacity:'.5'});
      
    }
    
    for (i=0;i < (xAxis+1);i++){
      var x = (i*this.options.grid.x)+this.options.offset.l;
      if (x < this.options.width)
        this.svg.path("M{0} {2} L{0} {1}",x,this.options.height,this.options.offset.t).attr({stroke:'#FFF',opacity:'.5'});
    }
       
  },
  drawFrame: function(){
    this.svg.path("M{2} {3}L{2} {0}L{1} {0}L{1} {3}L{2} {3}",this.options.height,this.options.width,this.options.offset.l,this.options.offset.t).attr({stroke:'#2F69BF',opacity:'1',fill: this.options.background,'fill-opacity':'.5'});
  }
}

Raphael.el.clone = function(paper){
  var res = {};
  if (this.hasOwnProperty("type")) {
    res = paper[this.type]();
    res.attr(this.attrs);
  }
  //console.log(paper.canvas);
  return paper.canvas.cloneNode(this);
}

Raphael.el.cloneN = function(paper,x,y){
  //console.log(this);
  var clone = this.node.cloneNode(false);
  //console.log(clone+"\nx:"+x+"\ny:"+y);
  return paper.canvas.appendChild(clone);
}
