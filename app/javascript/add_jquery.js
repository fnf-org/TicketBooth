import jquery from "jquery";

window.jQuery = jquery;
window.$ = jquery;

// https://dev.to/nejremeslnici/how-to-use-view-transitions-in-hotwire-turbo-1kdi
addEventListener("turbo:before-frame-render", (event) => {
  if (document.startViewTransition) {
    const originalRender = event.detail.render
    event.detail.render = (currentElement, newElement) => {
      document.startViewTransition(() => originalRender(currentElement, newElement))
    }
  }
})


// open a popup
window.popupWindow = function(url, windowName, win, w, h) {
  const y = win.top.outerHeight / 2 + win.top.screenY - (h / 2);
  const x = win.top.outerWidth / 2 + win.top.screenX - (w / 2);
  return win.open(url, windowName, `toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width=${w}, height=${h}, top=${y}, left=${x}`);
};
