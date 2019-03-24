// define color scale for markers
var colorScale = [
  "#adff2f",
  "#d9ef8b",
  "#ffffbf",
  "#fee08b",
  "#fdae61",
  "#f46d43",
];

// mapbox url and attribution
var mapboxUrl = "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}";
var mapboxAttrib = "Map data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"http://mapbox.com\">Mapbox</a>";
// Creating map object
var map = L.map("map-id").setView([40.73, -74.0059], 2);

// mapbox.streets mapbox.light mapbox.dark mapbox.satellite mapbox.streets-satellite
// mapbox.wheatpaste mapbox.streets-basic mapbox.comic mapbox.outdoors mapbox.run-bike-hike
// mapbox.pencil mapbox.pirates mapbox.emerald mapbox.high-contrast
// Create the tile layer that will be the background of our map
var satmap = L.tileLayer(mapboxUrl, {
  attribution: mapboxAttrib,
  maxZoom: 20,
  id: "mapbox.streets-satellite",
  accessToken: API_KEY
});

// Create a tile layer that will be the background of our map
var lightmap = L.tileLayer(mapboxUrl, {
  attribution: mapboxAttrib,
  maxZoom: 20,
  id: "mapbox.light",
  accessToken: API_KEY
});

// Create a tile layer that will be the background of our map
var outmap = L.tileLayer(mapboxUrl, {
  attribution: mapboxAttrib,
  maxZoom: 20,
  id: "mapbox.outdoors",
  accessToken: API_KEY
});

// Create baseMaps object
var baseMaps = {
  "Satellite": satmap,
  "Greyscale": lightmap,
  "Outdoors": outmap,
};

// add satellite layer to map
baseMaps["Satellite"].addTo(map);

// Create an empty overlay object
var overlayMaps = {};

// Create a legend to display information about our map
var legend = L.control({ position: "bottomright" });

// When the layer control is added, insert a div with the class of "legend"
legend.onAdd = function () {

  var div = L.DomUtil.create('div', 'info legend'); // create a div with a class "info" and "legend"
  var clen = colorScale.length;
  var labels = colorScale.slice(0, clen - 1).map((d, i) => `<i style="background: ${d}"></i>${i}-${i + 1}<br>`);
  labels.push(`<i style="background: ${colorScale[clen - 1]}"></i>${clen - 1}+<br>`);
  div.innerHTML = labels.join("");
  return div;
};

// Add legend to the map
legend.addTo(map);

// Initialize an object containing icons for each layer group
function getMarkerStyle(m) {

  // convert float to int
  var cidx = ~~m;
  // saturate to 5
  cidx = (cidx > 5) ? 5 : cidx;

  return {
    radius: m * 4,
    fillColor: colorScale[cidx],
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.7,
  };
}

function urlError(resp) {
  console.log('Metadata URL Error!')
  console.log(resp);
}

function earthquakeFeatures(edata) {

  // Creating a geoJSON layer with the retrieved earthquake data
  return L.geoJson(edata, {

    pointToLayer: function (feature) {
      return L.circleMarker(
        L.latLng({ lon: feature.geometry.coordinates[0], lat: feature.geometry.coordinates[1], }),
        getMarkerStyle(feature.properties.mag)
      );
    },
    onEachFeature: function (feature, layer) {
      // bind popup with display info on click

      var p = `<h6>${feature.properties.place}</h6>`;
      var t = `<b>Time:</b> ${new Date(feature.properties.time)}<br>`;
      var m = `<b>Magnitude:</b> ${feature.properties.mag}<br>`;
      var ln = `<b>Longitude:</b> ${feature.geometry.coordinates[0]}<br>`;
      var la = `<b>Latitude:</b> ${feature.geometry.coordinates[1]}<br>`;
      var d = `<b>Depth:</b> ${feature.geometry.coordinates[2]} km<br>`;
      layer.bindPopup(p + "<hr>" + t + m + la + ln + d);
    },
  });
}

function plateFeatures(pdata) {

  // Creating a geoJSON layer with tectonic plate data
  return L.geoJson(pdata, {
    style: {
      "color": "red",
      "weight": 2,
      "opacity": 0.5,
      "fillOpacity": 0,
    },
    onEachFeature: function (feature, layer) {
      // bind popup with display info on click

      var p = `<h6>${feature.properties.PlateName}</h6>`;
      layer.bindPopup(p);
    },
  });
}

// Store our API endpoint inside queryUrl
// var queryUrl = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_week.geojson";
var queryUrl = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_month.geojson";
// Grabbing our GeoJSON data..
d3.json(queryUrl).then(function (resp) {

  // create geojson layers and add to layergroup
  overlayMaps["Fault Lines"] = L.layerGroup([plateFeatures(plateData)]);
  overlayMaps["Earthquakes"] = L.layerGroup([earthquakeFeatures(resp)]);

  updateMap();

}, urlError);

function updateMap() {

  // Create a control for our layers, pass our map layers into our layer control
  // Add the layer control to the map
  L.control.layers(baseMaps, overlayMaps, {
    collapsed: false
  }).addTo(map);

  overlayMaps["Earthquakes"].addTo(map);
}
