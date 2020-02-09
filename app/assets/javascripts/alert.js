document.addEventListener("DOMContentLoaded", () => {
  Array.from(document.getElementsByClassName("close")).forEach(alert => {
    alert.addEventListener("click", event => {
      event.target.parentElement.style.display = "none";
    });
  });
});
