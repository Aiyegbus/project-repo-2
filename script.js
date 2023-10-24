document.addEventListener("DOMContentLoaded", function () {
    const heading = document.querySelector("h1");
    heading.addEventListener("click", function () {
        heading.innerText = "Hello, Web!";
    });
});
