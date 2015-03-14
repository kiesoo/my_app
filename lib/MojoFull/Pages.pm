package MojoFull::Pages;

use Mojo::Base 'Mojolicious::Controller';
use MojoFull::Users qw( check );
use DateTime;

use URI::GoogleChart;
use LWP::Simple qw(getstore);
use Date::Manip;

use Cwd;

sub index {
	my $self = shift;
	
	MojoFull::Users->check(); #TO DO check if user is logged in
warn "dupa check";
	my $dt = DateTime->now;
	
	my $month = $dt->month < 10 ? '0' . $dt->month : $dt->month;
	my $days_in_month =  Date_DaysInMonth( $dt->month, $dt->year );

	my $end_date = $dt->year . '-' . $dt->month . '-' . $days_in_month; 
warn $end_date . " end date";
	my $data = $self->db->resultset('PageIp')->search(
				 {
					"DATEPART(mm, data)" =>  $month 
				},
				
				{
					select   => [ 'data', { count => 'id_ip' } ],
					as       => [qw/ data id_ip /],
					group_by => [qw/ data /] 
				}
		);

	use Data::Dumper;
#print Dumper($data) . " data pages index";
	my @all_day = ();

	$all_day[$_] = 0 foreach (1..$days_in_month);

	while (my $user = $data->next()) {
		my $m = '';
		if ($user->data =~ /\d{4}-\d{2}-(\d{2})/){
			$m = $1 ;
			$all_day[$m] = $user->get_column('id_ip');
		}
		
	}

	my $x = "0:";
	$x .= "|$_" foreach (1..$days_in_month);

	shift @all_day;
	#warn Dumper( @all_day) . " all day all night";
	my $chart = URI::GoogleChart->new("lines", 850, 320,
    
		data => \@all_day,
		range_show => "left",
		range_round => 1,
	
		margin => 5,
		color => ["blue"],
		label => ["Number of visitors on days in the current month"],
		chxl => $x,
		chxt => "x", 
	
		chyl => [1..20],
		chyt => "y",
	);

	my $cwd = getcwd();
	$cwd =~ s/\\/\//g;

	# save chart to a file
		# save chart to a file
	my $users_chart = "/images/reports/users1.png";
	getstore($chart, "$cwd/public$users_chart");
	
	$self->render(
		'pages/index',
		pages => $users_chart,
		reports => 'active',
		users => 'none',
		home => 'none'
	);
}


sub a_month {
	my $self = shift;
	
	$self->render(
		'pages/a_month',
		reports => 'active',
		users => 'none',
		home => 'none'
	);
}

sub month{
	my $self = shift;
	
	my $month =$self->param('id');
	my $dt = DateTime->now;

	my $year = $dt->year; 

	my $data = $self->db->resultset('Page')->search(
				{
					"DATEPART(mm, data)" =>  $month,
					"DATEPART(yy, data)" =>  $year,
				},
				{
					select   => [ 'data', { count => 'id' } ],
					as       => [qw/ data page /],
					group_by => [qw/ data /]
				}
		);
		
	my @all_day = ();
	
	my $date2 = DateTime->last_day_of_month(  
		year  => $year,
		month => $month,
	);
	warn $date2->day . " data";
	my $last_day_of_month = $date2->day;
	$all_day[$_] = 0 foreach (1..$last_day_of_month);
	
	while (my $user = $data->next) {
		my $m = '';
		if ($user->data =~ /\d{4}-\d{2}-(\d{2})/){
			$m = $1 ;
			$all_day[$m] = $user->page;
		}
		
	}

	my $x = "0:";
	$x .= "|$_" foreach (1..$last_day_of_month);

	shift @all_day;
	
	my $chart = URI::GoogleChart->new("lines", 850, 320,
    
	data => \@all_day,
    range_show => "left",
    range_round => 1,
	
	margin => 5,
    color => ["blue"],
    label => ["Number of visitors on days"],
    chxl => $x,
    chxt => "x", 
	
	chyl => [1..10],
    chyt => "y",
	);

	my $cwd = getcwd();
	$cwd =~ s/\\/\//g;

		# save chart to a file
	my $users_chart = "/images/reports/months.png";
	getstore($chart, "$cwd/public$users_chart");
	
	$self->render(
		pages => $users_chart,
		reports => 'active',
		users => 'none',
		home => 'none'
	);
}
sub a_day {
	my $self = shift;
	
	$self->render(
		'pages/a_day',
		reports => 'active',
		users => 'none',
		home => 'none'
	);
}
sub day{
    my $self = shift;

	my $day =$self->param('id');

	my $data = $self->db->resultset('Page')->search(
				{   data => $day},
				{
					select   => [ { count => 'id' }, 'page' ],
					as       => [qw/ id page/],
					group_by => [qw/ page /]
				}
		);
		
	my @pages = ();
	my @numbers = ();
	
	
	while (my $page = $data->next) {
		push @pages, $page->page."(".$page->id.")";
		push @numbers, $page->id;
	}
	
	my $chart = URI::GoogleChart->new("vertical-stacked-bars", 850, 320,
		data => \@numbers,
		range_show => "bootom",
		background => "transparent",
		label => \@pages,
		cht => "bvs",
		chco=> "FFC6A5|FFFF42|DEF3BD|00A5C6|DEBDDE|FF0000|00FF00|0000FF,FFC6A5|DEF3BD|C6EFF7"
	);

	my $cwd = getcwd();
	$cwd =~ s/\\/\//g;

	# save chart to a file
	my $day_chart = "/images/reports/day1.png";
	getstore($chart, "$cwd/public$day_chart");
	
	$self->render(
		pages => $day_chart,
		reports => 'active',
		users => 'none',
		home => 'none'
	);
}
sub page {
	my $self = shift;
	
	my $dt = DateTime->now;

	#my $start_date = $dt->year.'-'.($dt->month < 10 ? '0'.$dt->month : $dt->month); 
	#my $end_date = $dt->year.'-'.$dt->month.'-'.'31'; 
	my $month = $dt->month < 10 ? '0'.$dt->month : $dt->month;
	my $year = $dt->year;

	my $page_counts = $self->db->resultset('PageIp')->search(
				{
					"DATEPART(mm, data)" =>  $month,
					"DATEPART(yy, data)" =>  $year,
				},
				{
					select   => [ 'id_pg', { count => 'data' } ],
					as       => [qw/ page_id page_count/],
					group_by => [qw/ id_pg /]
				}
		);
	

	my @pages = ();
	my @values = ();
	my $i = 0;
	
	while ( my $page = $page_counts->next ) {

		$values[$i] = $page->get_column('page_count');
		my $x = $page->get_column('page_count');

		my $page_url = $self->db->resultset('Page')->search(
				{
					id =>  $page->get_column('page_id'),
				},
				{
					columns   => [ 'page' ],
				}
		)->first()->page;

		my $p = $page_url;
		$pages[$i] = $p."($x)";	
		$i++;
	}
	
	my $x = "0:";
	$x .= "|$_" foreach (@pages);
	warn scalar @pages . " scalar de pages";
	warn scalar @values . " scalar de values";
	my $chart = URI::GoogleChart->new("pie", 850, 320,
    
	data => \@values,
    range_show => "left",
    range_round => 1,
	
	margin => 5,
    color => ["blue"],
    label => \@pages,
    chxl => $x,
    chxt => "x", 
	chco=> "FFC6A5|FFFF42|DEF3BD|00A5C6|DEBDDE|FF0200|00FF0C|0300FF|C6EFF7|FFDEA5|FFAE42|DE23BD|0fA5C6"
	);

	my $cwd = getcwd();
	$cwd =~ s/\\/\//g;

	# save chart to a file
	my $pages_chart = "/images/reports/pages1.png";
	warn Dumper($chart). "chart";
	use Data::Dumper;
	getstore($chart, "$cwd/public$pages_chart");

	$self->render(
		'/pages/page',
		pages_chart => $pages_chart,
		reports => 'active',
		users => 'none',
		home => 'none'
	);
}

1;
