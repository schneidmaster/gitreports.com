document.addEventListener("DOMContentLoaded", () => {
  // Navbar and dropdowns
  const toggle = document.getElementsByClassName("navbar-toggle")[0];
  const collapse = document.getElementsByClassName("navbar-collapse")[0];
  const dropdowns = Array.from(document.getElementsByClassName("dropdown"));

  // Toggle if navbar menu is open or closed
  const toggleMenu = () => {
    collapse.classList.toggle("collapse");
    collapse.classList.toggle("in");
  };

  // Close all dropdown menus
  const closeMenus = () => {
    dropdowns.forEach(dropdown => {
      dropdown
        .getElementsByClassName("dropdown-toggle")[0]
        .classList.remove("dropdown-open");
      dropdown.classList.remove("open");
    });
  };

  // Add click handling to dropdowns
  dropdowns.forEach(dropdown => {
    dropdown.addEventListener("click", () => {
      if (document.body.clientWidth < 768) {
        const open = this.classList.contains("open");
        closeMenus();
        if (!open) {
          this.getElementsByClassName("dropdown-toggle")[0].classList.toggle(
            "dropdown-open"
          );
          this.classList.toggle("open");
        }
      }
    });
  });

  // Close dropdowns when screen becomes big enough to switch to open by hover
  const closeMenusOnResize = () => {
    if (document.body.clientWidth >= 768) {
      closeMenus();
      collapse.classList.add("collapse");
      collapse.classList.remove("in");
    }
  };

  // Event listeners
  window.addEventListener("resize", closeMenusOnResize, false);
  toggle.addEventListener("click", toggleMenu, false);
});
