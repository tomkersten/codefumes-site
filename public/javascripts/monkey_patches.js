Array.prototype.unique = function () {
  var o = new Object();
  var i, e;
  
  for (i = 0; e = this[i]; i++) {
    o[e] = 1
  };
  var a = new Array();
  for (e in o) {
    a.push (e)
  };
  
  return a;
}

Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

Array.max = function( array ){
    return Math.max.apply( Math, array );
};

Array.min = function( array ){
    return Math.min.apply( Math, array );
};