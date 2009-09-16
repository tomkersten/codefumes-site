var Grid = function(canvas,options){

  this.options = $.extend({
      width: 500,
      height: 200,
      grid: {x:20, y:40},
      axis: {x:100, y:80}
  }, options);
  
  this.svg = Raphael(document.getElementById(canvas), this.options.width+1, this.options.height+1);
  
  this.drawGrid(this.options.axis.x,this.options.axis.y);
  
  return this.svg;
  
}

Grid.prototype = {

  drawGrid: function(xAxis,yAxis){
  
    for (i=0;i < (yAxis+1);i++){
      var y = i*this.options.grid.y;
      this.svg.path("M0 {0}L{1} {0}",y,this.options.width).attr({stroke:'#000',opacity:'.2'});
      
    }
    
    for (i=0;i < (xAxis+1);i++){
      var x = (i*this.options.grid.x);
      this.svg.path("M{0} 0 L{0} {1}",x,this.options.height).attr({stroke:'#000',opacity:'.2'});
    }   
       
  }
}
