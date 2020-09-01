//= require leaflet

$(() => {
  const mapId = "map";
  const $map = $(`#${mapId}`);

  var map = L.map('map').setView({lon: 0, lat: 0}, 2);;
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap contributors</a>'
  }).addTo(map);
});




