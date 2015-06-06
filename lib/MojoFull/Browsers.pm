package MojoFull::Browsers;

use Mojo::Base 'Mojolicious::Controller';

use DateTime;

use URI::GoogleChart;
use LWP::Simple qw(getstore);

sub browser {
    my $self = shift;

    $self->render(
        'browsers/browser',
        reports => 'active',
        users => 'none',
        home => 'none'
    );
}

#get browser data for the current month in the current year
sub browser_data {
    my $self = shift;

    my $dt = DateTime->now;

    my $month = $dt->month < 10 ? '0' . $dt->month : $dt->month;
    my $year = $dt->year;

    #Browsers Chart Data Select
    my @data = $self->db->resultset( 'BrowserIp' )->search (
                    {
                        "DATEPART(mm, data)" =>  $month,
                        "DATEPART(yy, data)" =>  $year,
                     },
                    {
                        select   => [ { count => 'data' }, 'id_br' ],
                        as       => [ qw/ browser_count id_browser / ],
                        group_by => [ qw/ id_br / ]
                    });

    my @browser_data = ();

    foreach my $browser ( @data ){
        my $browser_name = $self->db->resultset( 'Browser' )->search(
                {
                    id =>  $browser->get_column( 'id_browser' ),
                },
                {
                    columns   => [ 'browser' ],
                }
        )->first()->browser;

        push @browser_data, [ $browser_name, $browser->get_column( 'browser_count' ) ];
    }

    $self->render( json => \@browser_data );
}

sub os {
    my $self = shift;

    $self->render(
        reports => 'active',
        users => 'none',
        home => 'none'
    );
}

sub os_data {
    my $self = shift;

    my $dt = DateTime->now;

    my $month = $dt->month < 10 ? '0' . $dt->month : $dt->month;
    my $year = $dt->year;

    #SO Chart
    my @data = $self->db->resultset( 'OsIp' )->search (
                    {
                        "DATEPART(mm, data)" =>  $month,
                        "DATEPART(yy, data)" =>  $year,
                    },
                    {
                        select   => [ { count => 'data' }, 'id_os' ],
                        as       => [ qw/ os_count id_os / ],
                        group_by => [ qw/ id_os / ]
                    }
                );

    my @os_data = ();
    my @counts = ();

    foreach my $browser ( @data ) {
        my $os_name = $self->db->resultset( "OperatingSistem" )->search (
                        {
                            id =>  $browser->get_column('id_os'),
                        },
                        {
                            columns => [ 'name' ],
                        }
                    )->first()->name;

        push @os_data, [ $os_name, $browser->get_column( 'os_count' ) ];
    }

    $self->render( json => \@os_data );
}


1;
