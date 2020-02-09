const checkStatus = () => {
  fetch("/repositories/load_status", {
    credentials: "same-origin"
  })
    .then(response => {
      return response.text();
    })
    .then(data => {
      document.getElementById("repo-alert").style.display = "block";
      if (data === "true") {
        document.getElementById("repo-load-info").innerHTML =
          "Repositories refreshed! Click <a href='/profile'>here</a> to reload.";
      } else {
        setTimeout(checkStatus, 1000);
      }
    });
};

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("repo-alert")) {
    checkStatus();
  }
});
