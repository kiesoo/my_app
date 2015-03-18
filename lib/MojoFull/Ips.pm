package MojoFull::Ips;

use Mojo::Base 'Mojolicious::Controller';

use DateTime;

use URI::GoogleChart;
use LWP::Simple qw(getstore);

use Cwd;

sub users{
    my $self = shift;

    #User Trail Chart
    my @data = $self->db->resultset( 'Ip' )->all();

    my $ips = {};

    foreach my $page ( @data ) {
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
    my ( $self ) = @_;

    my $cwd = getcwd();
    $cwd =~ s/\\/\//g;

    my $id = $self->param( 'id' );

    my @data = $self->db->resultset( 'PageIp' )->search (
                    {
                        id_ip => $id
                    },
                    {
                        select   => [ { count => 'data' }, 'id_pg' ],
                        as       => [qw/ page_count page_id /],
                        group_by => [qw/ id_pg /]
                    }
                );

    my @pages_data = ();

    foreach my $page ( @data ) {
        my $page_url = $self->db->resultset( 'Page' )->search(
                {
                    id =>  $page->get_column( 'page_id' ),
                },
                {
                    columns   => [ 'page' ],
                }
        )->first()->page;

        push @pages_data, [ $page_url, $page->get_column( 'page_count' )];
    }

    $self->render( json => \@pages_data );
}

1;
