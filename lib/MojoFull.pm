package MojoFull;
use Mojo::Base 'Mojolicious';
use Schema;

has schema => sub {
    return Schema->connect('dbi:ODBC:DRIVER={SQL Server};SERVER={ADELA-PC};Database=web_new', '', '');
};

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->helper(db => sub { $self->app->schema });



    # Routes
    my $r = $self->routes;
    my $auth_bridge = $r->bridge('/')->to('users#check');

    $r->route('/')->to('users#login');
    $r->route('/users/home')->to('users#home');
    $r->route('/users/all')->to('users#all');
    $r->route('/users/register')->to('users#register');
    $auth_bridge->route('/users/delete')->to('users#delete');

    $auth_bridge->route('/pages')->to('pages#index');
    $auth_bridge->route('/pages/month')->to('pages#month');
    $auth_bridge->route('/pages/a_month')->to('pages#a_month');
    $auth_bridge->route('/pages/day')->to('pages#day');
    $auth_bridge->route('/pages/a_day')->to('pages#a_day');
    $auth_bridge->route('/pages/page')->to('pages#page');
    $auth_bridge->route('/pages/page_data')->to('pages#page_data');
    $auth_bridge->route('/pages/pages_current_month_data')->to('pages#pages_current_month_data');


    $auth_bridge->route('/ips')->to('ips#users');
    $auth_bridge->route('/ips/users')->to('ips#users');
    $auth_bridge->route('/ips/trail')->to('ips#trail');

    $auth_bridge->route('/browsers/browser')->to('browsers#browser');
    $auth_bridge->route('/browsers/os')->to('browsers#os');
    $auth_bridge->route('/browsers/browser_data')->to('browsers#browser_data');

    $r->route('/register')->to('users#register');
    $r->route('/users/home')->to('users#home');
    $r->route('/register/success')->to('users#success');
    $r->route('/login')->to('users#login');
    $r->route('/logout')->to('users#logout');
}

1;
