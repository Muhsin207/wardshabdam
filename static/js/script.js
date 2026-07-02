function openMenu() {
    document.getElementById("sidebar").classList.add("active");
}

function closeMenu() {
    document.getElementById("sidebar").classList.remove("active");
}

function openLoginModal() {
    document.getElementById("loginModal").style.display = "flex";
}

function closeLoginModal() {
    document.getElementById("loginModal").style.display = "none";
}

window.onclick = function(event) {

    let modal = document.getElementById("loginModal");

    if(event.target == modal){

        modal.style.display = "none";

    }

}