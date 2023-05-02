#!/usr/bin/perl
require 5.16.0; use strict; use warnings;

my $VERSION = 1.0;

# Plain Old Documentation (POD)
# run "perldoc food_trucks.pl" to read this documentation properly formatted

=head1 NAME

food_trucks.pl -- locate the closest food trucks

=head1 SYNOPSIS

	$.ajax({
		type: 'GET',
		url: 'food_trucks.pl',
		dataType: 'json',
		data: {	lon:	-122.4,
			lat:	37.8,
			type:	tacos,
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

=head1 DESCRIPTION

Food truck locator app finds the closest trucks serving a particular type of food.

Parameters
=over 4
	lon = longitude of your location or where you will be
	lat = latitude of your location or where you will be
	type (optional) = the type of food you want to order
	limit (optional) = how many results to return
=back

Returns JSON object with:
=over 4
	error - containing any error messages
	results - array of the closest food trucks serving the desired fare
=back

=head1 AUTHOR

Thomas Anderson C<< <tanderson@orderamidchaos.com> >>

=head1 COPYRIGHT
Copyright 2023, Thomas Anderson
This program is licensed under the GNU General Public License 2.0

=head1 SUPPORT
GitHub repository at:
	L<https://github.com/orderamidchaos/food_trucks>
=cut

# use tab width = 8 for proper alignment of this code in a fixed-width font

#################################################
############# Configuration Options #############
#################################################

# adjust these as necessary to access the food truck API
my $api_protocol	= "https";
my $api_host		= "data.sfgov.org";
my $api_resource	= "czpa-xmbm";
my $api_method		= "GET";
my $api_app_token	= "";
my $api_results		= 5000;

#################################################
############## Include Libraries ################
#################################################

# make sure to install these modules before running
use CGI;
use LWP::UserAgent;
use HTTP::Request;
use URI;
use JSON;
use Sort::Key::Multi qw(n2keysort_inplace);

#################################################
#################### Main #######################
#################################################

my $data = {error => "", results => {}};
get_cgi_params($data);
sort_trucks($data) unless $data->{error};
output_json($data);

#################################################
################## Functions ####################
#################################################

sub get_cgi_params {
	my $data	= $_[0];
	my $cgi		= new CGI;

	foreach my $name ($cgi->url_param())	{ if ($name and $name =~ /^lat|lon|type|limit$/) { $data->{$name} = $cgi->url_param($name); }}	# get querystring data
	foreach my $name ($cgi->param())	{ if ($name and $name =~ /^lat|lon|type|limit$/) { $data->{$name} = $cgi->param($name); }}	# get post data
	if (defined $cgi->param('POSTDATA')) {													# get json data
		my $jsondata = JSON->new->utf8->decode($cgi->param('POSTDATA'));
		foreach my $name (keys (%{$jsondata})) { if ($name and $name =~ /^lat|lon|type|limit$/) { $data->{$name} = $jsondata->{$name}; }}}

	$data->{error} .= "Failed to get CGI parameters\n" unless $data->{lat} and $data->{lon}; }

sub fetch_api {
	my $data	= $_[0];
	my $agent	= "Perl Food Truck API Client/$VERSION";
	my $ua		= LWP::UserAgent->new(agent => $agent) or $data->{error} .= "Create user agent failed\n";
	my $uri		= URI->new("$api_protocol://$api_host/resource/$api_resource/");
			$uri->query_param("$limit" => $api_results) if $api_results;
			$uri->query_param("fooditems" => $data->{type}) if $data->{type};
	my $request	= HTTP::Request->new($api_method, $uri);
			$request->header("Accept" => "application/json");
			$request->header("X-App-Token" => $api_app_token) if $api_app_token;
	my $response	= $ua->request($request) or $data->{error} .= "HTTP request failed\n";

	return $response->is_success()? JSON->new->utf8->decode($response->decoded_content) : []; }

sub sort_trucks {
	my $data	= $_[0];
	my $trucks	= fetch_api($data);
	$data->{error} .= "Failed to get truck list\n" unless is_array($trucks);

	unless ($data->{error}) {
		@{$trucks} = map {
			$trucks->[$_]->{longitude} = abs($data->{lon} - $trucks->[$_]->{longitude});			# make the longitude the distance from you
			$trucks->[$_]->{latitude} = abs($data->{lat} - $trucks->[$_]->{latitude}) } @{$trucks};		# make the latitude the distance from you
		n2keysort_inplace { $_->{longitude}, $_->{latitude} } @{$trucks};					# sort trucks by latitude & longitude distance
		$data->{results} = $data->{limit}? [@$trucks[0..($data->{limit}-1)]] : $trucks;				# slice the array if a limit was specified
	}}

sub is_array {
	my $ref = $_[0];
	unless (defined $ref and ref $ref)			{ return 0; }
	else { 	use warnings; use strict;
		eval { my $a = @$ref; };
		if ($@=~/^Not an ARRAY ref/)			{ return 0; }
		elsif ($@)					{ return 0; }
		else						{ return 1; }}}

sub output_json {
	my $data	= $_[0];
	my $cgi		= new CGI;
	my $json	= JSON->new->utf8->encode($data);

	print $cgi->header(
                    -type    => 'application/json',
                    -charset => 'charset=UTF-8');
	print $json; }
