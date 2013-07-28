document.body.oncontextmenu = function() {
  alert('Please dont right click!!')
  return window.event.shiftKey // top secret
 }

if (window.self === window.top && !window.isIndex) { // uh oh! unframed!!
  var title = document.title + ' - '
  setInterval(function(){
    title = title.slice(1) + title[0];
    document.title = title;
  }, 1000)
  var template = '<FRAMESET ROWS="80px,*">'
  template +=    '  <FRAME SRC="/title.html" NAME=TITLE SCROLLING=NO>'
  template +=    '  <FRAMESET COLS="222px,*">'
  template +=    '    <FRAME SRC="/side.html" NAME=side>'
  template +=    '    <FRAME SRC="'+ window.location.href  +'" NAME=main>'
  template +=    '  </FRAMESET>'
  template +=    '</FRAMESET>'
  document.getElementsByTagName('html')[0].innerHTML = template
}

var links = document.getElementsByTagName('a');
for (var i=0; i < links.length; i++) {
  var link = links[i]
  link.onclick = (function(link) {
    return function() {
      if (link.target !== '_new') {
        window.parent.history.pushState(null, 'whatever', link.pathname)
      }
    }
  })(link)
}
