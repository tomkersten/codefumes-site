var SvgModal = function(options){

  this.options = $.extend({
      grid: {x:500/8, y:20},
      axis: {x:8, y:13},
      width: 500,
      height: 20*13
  }, options);
  this.svg = Raphael(0,0, this.options.width+1, this.options.height+1);
  this.svg.path("M0 20L15 10V1H200V100H15V30L0 20 Z").attr({fill: "#FFF",'fill-opacity':.5,stroke:'#ACD373'})

}

SvgModal.prototype = {
  moveTo: function(x,y){
    //console.log(this.svg);
    $(this.svg).animate({"left": x+"px","top": y+"px"}, "slow");
    
  }
 
}
