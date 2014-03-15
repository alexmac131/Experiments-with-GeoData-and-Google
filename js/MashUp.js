  var latlng;
  var marker;
  function initialize () {
    var mapOptions = {  
          zoom: 2, 
          center: new google.maps.LatLng(2.8,2.8), 
          mapTypeId: google.maps.MapTypeId.TERRAIN
    };

    var map = new google.maps.Map(document.getElementById("mapCanvas"),mapOptions  );
    console.log("alex");
    
    $.getJSON("data/canada.json", function(data) {
      latlngArray =  new google.maps.LatLng(data);
      //console.log(latlngArray);
      var populationOptions = {
          strokeColor: '#FF0000',
          strokeOpacity: 0.2,
          strokeWeight: 6,
          fillColor: '#FF0000',
          fillOpacity: 0.35,
          map: map,
          center: latlng,
          radius: 20000,
          } 

      for (var i = 0; i < data.length; i++) {
        populationOptions.center = new google.maps.LatLng(data[i].Latitude,data[i].Longitude);
        cityCircle = new google.maps.Circle(populationOptions);  

      }
    });  
  }
    
  function loadScript() {
      var script = document.createElement('script');
      script.type = 'text/javascript';
      script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp&?key=AIzaSyB_h_TZ3jVQstD6ieduDF482_kRIyF4y1I&sensor=false&' 
      + 'callback=initialize';
      document.body.appendChild(script);
      console.log("aaa");
  }
  window.onload = loadScript;



