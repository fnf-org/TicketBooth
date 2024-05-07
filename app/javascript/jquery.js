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
