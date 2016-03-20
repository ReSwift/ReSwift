window.jazzy = {'docset': false};

if (typeof window.dash != 'undefined') {
  document.documentElement.className += ' dash';
  window.jazzy.docset = true;
}

if (navigator.userAgent.match(/xcode/i)) {
  document.documentElement.className += ' xcode';
  window.jazzy.docset = true;
}

if (!window.jazzy.docset) {
  $(function() {
    var filename = window.location.pathname.split('/').pop();
    $('a[href="Documentation.html"]').attr('href', 'index.html');
    $('.navigation a[href$="/' + filename + '"]').addClass('current-page');
    $('.navigation a[href="' + filename + '"]').addClass('current-page');
  });
}
