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