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
  
  $r->route('/')->to('users#login');
  $r->route('/users/home')->to('users#home');
  $r->route('/users/all')->to('users#all');
  $r->route('/users/register')->to('users#register');
  $r->route('/users/delete')->to('users#delete');
  
  $r->route('/pages')->to('pages#index');
  $r->route('/pages/month')->to('pages#month');	
  $r->route('/pages/a_month')->to('pages#a_month');
  $r->route('/pages/day')->to('pages#day');	
  $r->route('/pages/a_day')->to('pages#a_day');
  $r->route('/pages/page')->to('pages#page');
  
  $r->route('/ips')->to('ips#users');
  $r->route('/ips/users')->to('ips#users');
  $r->route('/ips/trail')->to('ips#trail');
  
  $r->route('/browsers/browser')->to('browsers#browser');
  $r->route('/browsers/os')->to('browsers#os');
  
  $r->route('/register')->to('users#register');
  $r->route('/users/home')->to('users#home');
  $r->route('/register/success')->to('users#success');
  $r->route('/login')->to('users#login');
  $r->route('/logout')->to('users#logout');
  }

1;
