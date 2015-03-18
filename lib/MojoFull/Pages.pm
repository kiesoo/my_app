package MojoFull::Pages;

use Mojo::Base 'Mojolicious::Controller';
use DateTime;

use URI::GoogleChart;
use LWP::Simple qw(getstore);
use Date::Manip;

use Cwd;

sub index {
    my $self = shift;

    $self->render(
        'pages/index',
        reports => 'active',
        users => 'none',
        home => 'none'
    );
}

sub pages_current_month_data {
    my $self = shift;

    my $dt = DateTime->now;

    my $month = $dt->month < 10 ? '0' . $dt->month : $dt->month;

    my $days_in_month = Date_DaysInMonth( $dt->month, $dt->year );

    my $end_date = $dt->year . '-' . $dt->month . '-' . $days_in_month;

    my $data = $self->db->resultset( 'PageIp' )->search(
                {
                    "DATEPART( mm, data )" => $month
                },
                {
                    select   => [ 'data', { count => 'id_ip' } ],
                    as       => [qw/ day ip_count /],
                    group_by => [qw/ data /]
                }
        );

    my @all_days = ();

    #initialize array with 0
    $all_days[$_] = 0 foreach ( 1 .. $days_in_month );

    while ( my $user = $data->next() ) {
        my $day;

        if ($user->get_column( 'day' ) =~ /\d{4}-\d{2}-(\d{2})/){
            $day = $1 ;
            $all_days[$day] = $user->get_column('ip_count');
        }

    }

    my @visits_in_current_month = ();
    #remove first element which is undef
    while (my ( $day_index, $visits_per_day ) = each @all_days ) {
        push @visits_in_current_month, [ "$day_index", $visits_per_day ];
    }
    shift(@visits_in_current_month);

    $self->render( json => \@visits_in_current_month );
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

sub month {
    my $self = shift;

    my $month =$self->param('id');
    my $dt = DateTime->now;

    my $year = $dt->year;

    my $data = $self->db->resultset('PageIp')->search(
                {
                    "DATEPART(mm, data)" =>  $month,
                    "DATEPART(yy, data)" =>  $year,
                },
                {
                    select   => [ 'data', { count => 'id_ip' } ],
                    as       => [qw/ day ip_count /],
                    group_by => [qw/ data /]
                }
        );

    my @all_days = ();

    my $last_day_of_month = DateTime->last_day_of_month(
            year  => $year,
            month => $month,
        )->day;

    $all_days[$_] = 0 foreach ( 1 .. $last_day_of_month );

    while ( my $user = $data->next ) {
        my $day = '';

        if ( $user->get_column( 'day' )  =~ /\d{4}-\d{2}-(\d{2})/ ) {
            $day = $1;
            $all_days[$day] = $user->get_column('ip_count');
        }
    }

    my @visits_in_chosen_month = ();

    #remove first element which is undef
    while (my ( $day_index, $visits_per_day ) = each @all_days ) {
        push @visits_in_chosen_month, [ "$day_index", $visits_per_day ];
    }

    shift( @visits_in_chosen_month );

    $self->render( json => \@visits_in_chosen_month );
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

sub day {
    my $self = shift;

    my $day =$self->param('day');

    my $page_counts = $self->db->resultset( 'PageIp' )->search(
                {
                    "CONVERT( date, data )" => $day,
                },
                {
                    select   => [ { count => 'data' }, 'id_pg' ],
                    as       => [ qw/ page_count page_id / ],
                    group_by => [ qw/ id_pg / ]
                }
        );

    my @pages = ();
    my @values = ();
    my $i = 0;

    while ( my $page = $page_counts->next ) {
        $values[$i] = $page->get_column( 'page_count' );

        my $count = $page->get_column( 'page_count' );

        my $page_url = $self->db->resultset( 'Page' )->find(
                {
                    id =>  $page->get_column( 'page_id' ),
                },
        )->page;

        $pages[$i] = $page_url . "($count)";
        $i++;
    }

    my $cwd = getcwd();
    $cwd =~ s/\\/\//g;

    my $data_count = ( scalar( @pages ) && scalar( @values ) ) ? 1: 0;

    my $day_chart;
    if ( $data_count ) {
        my $chart = URI::GoogleChart->new( "vertical-stacked-bars", 850, 320,
            data => \@values,
            range_show => "bootom",
            background => "transparent",
            label => \@pages,
            cht => "bvs",
            chco=> "FFC6A5|FFFF42|DEF3BD|00A5C6|DEBDDE|FF0000|00FF00|0000FF,FFC6A5|DEF3BD|C6EFF7"
        );

        # save chart to a file
        $day_chart = "/images/reports/day1.png";
        getstore($chart, "$cwd/public$day_chart");
    }
    else {
        $day_chart = "/images/errors/a_day_no_data.png";
    }

    $self->render(
        pages => $day_chart,
        reports => 'active',
        users => 'none',
        home => 'none'
    );
}

sub page {
    my $self = shift;

    $self->render(
        '/pages/page',
        reports => 'active',
        users => 'none',
        home => 'none'
    );
}

sub page_data {
    my $self = shift;

    my $dt = DateTime->now;

    my $month = $dt->month < 10 ? '0' . $dt->month : $dt->month;
    my $year = $dt->year;

    my $page_counts = $self->db->resultset( 'PageIp' )->search(
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

    my @pages_data = ();

    while ( my $page = $page_counts->next ) {

        my $count = $page->get_column( 'page_count' );

        my $page_url = $self->db->resultset( 'Page' )->search(
                {
                    id =>  $page->get_column( 'page_id' ),
                },
                {
                    columns   => [ 'page' ],
                }
        )->first()->page;

        push @pages_data, [ $page_url, $count ];
    }

    $self->render( json => \@pages_data );
}

1;
