var drawrings = function(data){
  pageHeight = 200;
  this.points = data;
  this.handles =[];
  this.page = Raphael(50, 50, this.points.length*50, pageHeight);
  var line = this.page.path({stroke: "#ffa500", "stroke-opacity": 1,"stroke-width": 1, "stroke-linecap": "round","stroke-linejoin": "round"}).moveTo(40, pageHeight-this.points[0])
  this.points.each(function(point,index){
  this.plotPoint(line,pageHeight-point,(index+1)*40,index)
  }.bind(this));
  this.fade(line,"#ffa500",3000);
}
drawrings.prototype= {
  plotPoint: function(path,yAxis,xAxis,index){
    this.handles[index] = path.lineTo(xAxis,yAxis);
    this.setMarker(xAxis,yAxis);
  },
  setMarker: function(xAxis,yAxis){
    var page=this.page
    var c = this.page.circle(xAxis,yAxis,5);
    c.attr("stroke","#000");
    c.attr("fill","#000");
    c.attr("fill-opacity",".2");
    c.attr("opacity",.5);
    c.node.onclick = function(){
      var text = page.text(xAxis,yAxis,"position:"+yAxis);
      setTimeout(function(){text.hide()},3000);
    }
    c.node.onmouseover = function(){c.animate({"scale":"6,6"},500).attr("opacity",1)}
    c.node.onmouseout = function(){c.animate({"scale":"1,1"},500).attr("opacity",.5)}
  },
  fade: function(object,color,duration){
    fadeOut = function(){
      object.animate({"stroke-width": 1,"stroke-opacity": .1},duration);
      setTimeout(fadeIn,duration);
    }
    fadeIn = function(){
      object.animate({"stroke-width": 10,stroke: color,"stroke-opacity": 1},duration);
      setTimeout(fadeOut,duration);
    }
    fadeIn();
  }
}
var goop = new drawrings([32,35,36,42,35,37,40,29,31,31,31,40,48,45,44,46,50,53,55,44,57])

