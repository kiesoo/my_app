package MojoFull::Browsers;

use Mojo::Base 'Mojolicious::Controller';

use DateTime;

use URI::GoogleChart;
use LWP::Simple qw(getstore);

use Cwd;

sub browser {
	my $self = shift;

	my $cwd = getcwd();
	$cwd =~ s/\\/\//g;

	#Browsers Chart
	my @data = $self->db->resultset('BrowserIp')->search (
					{},
					{	
						select   => [ { count => 'data' }, 'id_br' ],
						as       => [qw/ browser_count id_browser /],
						group_by => [qw/ id_br /]
					});  
	my @browsers = ();
	my @numbers = ();

	foreach my $browser (@data){
		my $browser_name = $self->db->resultset('Browser')->search(
				{
					id =>  $browser->get_column('id_browser'),
				},
				{
					columns   => [ 'browser' ],
				}
		)->first()->browser;

		push @browsers, $browser_name."(".$browser->get_column('browser_count').")";
		push @numbers, $browser->get_column('browser_count');
	}

  warn scalar @browsers ;
  warn Dumper(@numbers) . " numbers";
  use Data::Dumper;
  
	my $chart = URI::GoogleChart->new("pie-3d", 850, 320,
		data => \@numbers,
		range_show => "left",
		range_round => 1,
		background => "transparent",
		label => \@browsers,
		chco=> "FFC6A5|FFFF42|DEF3BD|00A5C6|DEBDDE|FF0200|00FF0C|0300FF|C6EFF7|FFDEA5|FFAE42|DE23BD|0fA5C6"
	);

	# save chart to a file
	my $browser_chart = "/images/reports/browsers.png";
	getstore($chart,  "$cwd/public$browser_chart");
	$self->render(
		'browsers/browser',
		browser_chart => $browser_chart,
		reports => 'active',
		users => 'none',
		home => 'none'
	);
}

sub os{
	my $self = shift;

	my $cwd = getcwd();
	$cwd =~ s/\\/\//g;

	#SO Chart
	my @data = $self->db->resultset('OsIp')->search (
					{},
					{	
						select   => [ { count => 'data' }, 'id_os' ],
						as       => [qw/ os_count id_os /],
						group_by => [qw/ id_os /]
					}
				); 

	my @os = ();
	my @numbers = ();
	
	foreach my $browser (@data) {
		my $os_name = $self->db->resultset("OperatingSistem")->search (
						{
							id =>  $browser->get_column('id_os'),
						},
						{
							columns => [ 'name' ],
						}
					)->first()->name;
		push @os, $os_name . "(" . $browser->get_column('os_count') . ")";
		push @numbers, $browser->get_column('os_count');
	}
  
	my $chart = URI::GoogleChart->new("horizontal-stacked-bars", 850, 320,
		data => \@numbers,
		range_show => "bootom",
		background => "transparent",
		label => \@os,
		cht => "bhs",
		chco=> "FFC6A5|FFFF42|DEF3BD|00A5C6|DEBDDE|FF0000|00FF00|0000FF,FFC6A5|DEF3BD|C6EFF7"
	);

	# save chart to a file
	my $os_chart = "/images/reports/os.png";
	getstore($chart,  "$cwd/public$os_chart");
	
	$self->render(
		os_chart => $os_chart,
		reports => 'active',
		users => 'none',
		home => 'none'
	);
}


1;
