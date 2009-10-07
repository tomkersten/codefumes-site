var Grid = function(canvas,options){

  this.options = $.extend({
      width: 500,
      height: 200,
      background: '#CCC',
      grid: {x:20, y:40},
      axis: {x:100, y:80},
      offset: {r:0,t:0,l:0,b:0}
  }, options);
  
  this.svg = Raphael(document.getElementById(canvas), this.options.width+1, this.options.height+1);
  this.drawFrame();
  this.drawGrid(this.options.axis.x,this.options.axis.y);
  
  return this.svg;
  
}

Grid.prototype = {

  drawGrid: function(xAxis,yAxis){
  
    for (i=1;i < (yAxis+1);i++){
      var y = (i*this.options.grid.y)+this.options.offset.t;
      this.svg.path("M{2} {0}L{1} {0}",y,this.options.width,this.options.offset.r).attr({stroke:'#000',opacity:'.2'});
      
    }
    
    for (i=0;i < (xAxis+1);i++){
      var x = (i*this.options.grid.x)+this.options.offset.r;
      this.svg.path("M{0} {2} L{0} {1}",x,this.options.height,this.options.offset.t).attr({stroke:'#000',opacity:'.2'});
    }
       
  },
  drawFrame: function(){
    this.svg.path("M{2} {3}L{2} {0}L{1} {0}L{1} {3}L{2} {3}",this.options.height,this.options.width,this.options.offset.r,this.options.offset.t).attr({stroke:'#ACD373',opacity:'1',fill: this.options.background,'fill-opacity':'.5'});
  }
}
