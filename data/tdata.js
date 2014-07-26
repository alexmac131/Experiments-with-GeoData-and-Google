var tj = require('togeojson');
var fs = require('fs');
var jsdom = require('jsdom').jsdom;

var kml = jsdom(fs.readFileSync('TOURISM_LISTINGS.kml', 'utf8'));

var converted = tj.kml(kml);

var converted_with_styles = tj.kml(kml, { styles: true });

console.log ("[\n");

for (var i = 0;i < converted.features.length; i++) {
	console.log ("{");

	console.log ("gps : [" + converted.features[0].geometry.coordinates + "],");
	console.log ("name : \""  + converted.features[0].properties.name  +  "\",");
	console.log ("description : \"", converted.features[0].properties.DESCRIPTION, "\""  );
	console.log ("},\n");


}
console.log ("\n]\n");
//console.log (converted.features[0]);

