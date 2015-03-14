package MojoFull::Ips;

use Mojo::Base 'Mojolicious::Controller';

use DateTime;

use URI::GoogleChart;
use LWP::Simple qw(getstore);

use Cwd;

sub users{
	my $self = shift;
	
	#User Trail Chart
	my @data = $self->db->resultset('Ip')->all();

	my $ips = {};
	
	foreach my $page (@data){
		$ips->{$page->id}->{'ip'} = $page->ip_addr;
	}
	
	$self->render(
		'ips/users',
		ips_option => $ips,
		home => 'none',
		reports => 'active',
		users => 'none'
	);
}


sub trail{
	my ($self) = @_;

	my $cwd = getcwd();
	$cwd =~ s/\\/\//g;

	my $id = $self->param('id');

	my @data = $self->db->resultset('PageIp')->search (
					{	
						id_ip => $id 
					},
					{	
						select   => [ { count => 'data' }, 'id_pg' ],
						as       => [qw/ page_count page_id /],
						group_by => [qw/ id_pg /]
					}
				);  

	my @dates = ();
	my @numbers = ();
	my $x = "0:";

	foreach my $page (@data) {
		my $page_url = $self->db->resultset('Page')->search(
				{
					id =>  $page->get_column('page_id'),
				},
				{
					columns   => [ 'page' ],
				}
		)->first()->page;
warn $page_url . " page url";
warn  $page->get_column('page_count') . "page count";
		push @dates , $page_url;
		push @numbers , $page->get_column('page_count');
		$x .= "|" . $page_url . " ";
	}
	warn $x . " dolar x";
	my $chart = URI::GoogleChart->new("vertical-grouped-bars", 600, 250,
		data => [
			{ range => "a", v => \@numbers },
		],
		range => {
		a => { show => "left" },
		},
		label => \@dates,
		chxt => "x",
		chbh => "a",
		chco=> "FFC6A5|FFFF42|DEF3BD|00A5C6|DEBDDE|FF0200|00FF0C|0300FF|C6EFF7|FFDEA5|FFAE42|DE23BD|0fA5C6"
	);
	warn Dumper($chart) . "chart";
	use Data::Dumper;
	# save chart to a file
	my $ip_chart = "/images/reports/ip.png";
	my $rc = getstore($chart, "$cwd/public$ip_chart");
	warn $rc . "==================================";
	
	$self->render(
		ip_chart =>  $ip_chart,
		home => 'none',
		reports => 'active',
		home => 'none'
	);
}

1;
