# food_trucks.pl

locate the closest food trucks

# SYNOPSIS
```html
	<script type="text/javascript">
	$.ajax({
		type: 'GET',
		url: 'food_trucks.pl',
		dataType: 'json',
		data: {	lon:	-122.4,
			lat:	37.8,
			type:	'tacos',
			limit:	10 },
		success: function(data) {
		    if (data.error) { alert(data.error); }
		    else {
			print "<table>\n";
			for (var result in data.results) {
				print "<tr><td>"+result.applicant+"</td><td>"+result.address+"</td></tr>\n"; }
			print "</table>\n"; }},
		error: function(){
		    alert("handle errors here"); },
		complete: function() {}
	});
	</script>
```
# DESCRIPTION

Food truck locator app finds the closest trucks serving a particular type of food.

## Parameters

* lon = longitude of your location or where you will be
* lat = latitude of your location or where you will be
* type (optional) = the type of food you want to order
* limit (optional) = how many results to return

## Returns JSON object with:
```json
{
	"error" : "human-readable error string(s)",
	"results" : [*array of the closest food trucks serving the desired fare*]
}
```

# AUTHOR

Thomas Anderson <[tanderson@orderamidchaos.com](tanderson@orderamidchaos.com)>

# COPYRIGHT

Copyright 2023, Thomas Anderson

This program is licensed under the GNU General Public License 2.0

# SUPPORT

GitHub repository at:

[https://github.com/orderamidchaos/food_trucks](https://github.com/orderamidchaos/food_trucks)
