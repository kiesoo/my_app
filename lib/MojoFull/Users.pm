package MojoFull::Users;

use Mojo::Base 'Mojolicious::Controller';

use DateTime;

use Email::Valid;
use Digest::MD5 qw(md5_hex);
use MIME::Lite;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT =  qw( check );

sub home {
	my $self = shift;

	$self->check();

	$self->render (
		home => 'active',
		reports => 'none',
		users => 'none'
	);
}

sub all {
    my $self = shift;

	$self->check();

	my @users = $self->db->resultset('User')->all();
    $self->render (
		home => 'none',
		reports => 'none',
		users => 'active',
        all_users => \@users
    );
}

sub register {
    my $self = shift;

    my $validator;

    #register action required
    if ( $self->param( 'register' ) ) {

        $validator = $self->__validate( $self->param() );
        return $self->render(validator => $validator) if $validator;

        my $user = $self->db->resultset( 'User' )->find_or_create( 
		{
            email => $self->param( 'email' ),
            password	=> (md5_hex $self->param( 'password') ),
            first_name	=> $self->param( 'first_name' ),
            last_name	=> $self->param( 'last_name' ),
            genre		=> $self->param( 'genre' ),
			type		=> $self->param( 'type' ),
            active		=> 1,
        });

        $self->session( data => undef );

        #warn "Activation link : http://localhost:3000/users/activate/".$inactive_user->user_id."/".$inactive_user->secret_key;

        #send email
        #my $msg = MIME::Lite->new(
        #    From    => 'users@Wa.com',
        #    To      => $self->session('User_email'),
        #    Subject => 'Your activation link',
        #    Type    => 'TEXT',
        #    Data    => "Activation link : http://localhost:3000/users/activate/".$inactive_user->user_id."/".$inactive_user->secret_key
        #);
        #
        #MIME::Lite->send('smtp', '127.0.0.1', Timeout => 10);
        #$msg->send;

        $self->redirect_to('/register/success');   
    }

	$self->render (
		validator => $validator,
		reports => 'none',
		users => 'none',
		home => 'none'
	);
}

sub __validate{
    my $self = shift;
    
    my $valid = undef;
    my $validator = {
		email => '',
		password => '',
		password_confirm => '',
    };
    
    #valid email address
    if  ( Email::Valid->address( $self->param( 'email' ) ) ) {
        #lookup for a user with given email address
        my $user = $self->db->resultset( 'User' )->search( email => $self->param( 'email' ) )->first();
        
        if ( $user ) {
            $validator->{ email } = 'Already have a user with this e-mail';    
            $valid = 1;
        }
    } #invalid email address
    else {
        $validator->{ email } = 'Invalid email format';
        $valid = 1;
    }
    
    if ( length( $self->param( 'password' ) ) < 6 ) {
        $validator->{ password } = 'Password must be a minimum of 6 characters';
        $valid = 1;
    }
	elsif ( $self->param( 'password' ) ne $self->param( 'password_confirm' ) ) {
        $validator->{ password_confirm } = 'Passwords do not match';
        $valid = 1;
    }
    
    #store params to session (don't lose form input data)
    my $data;
    foreach my $key ( $self->param() ) {
        $data->{ Users }->{ $key } = $self->param( $key );
    }
    
    $self->session( data => $data );
    
    #validation not passed
    return $validator if ( $valid );
    
    #validation passed
    return $valid;
}

#success : just display the register success view
sub success {}

sub login {
    my $self = shift;
    
    #redirect to home page if user alredy logged in
    $self->redirect_to( '/users/home' ) if ( $self->session( 'User_id' ) );
   
    #login action
    if ( $self->param( 'login' ) ) {
        my $user = $self->db->resultset('User')->search(
            {	email => $self->param('email'),
				password => (md5_hex $self->param('password'))
			}
        )->first();

        if ($user ) {
            my $user_type = $self->__login( $user );
            $self->redirect_to( '/users/home' );
            
        }
		else {
            $self->render (
                error => 'Invalid username/password',
				reports => 'none',
				users => 'active',
				home => 'none'
            );   
        }    
    }
	else {
        $self->render (
            error => 0,
			reports => 'none',
			users => 'active',
			home => 'none'
        );
    }
}

#__login : store given user in session
sub __login{
    my ( $self, $user ) = @_;
    
    #store user in session
    $self->session( User_id => $user->id );
    $self->session( User_email => $user->email );
    $self->session( User_first_name => $user->first_name );
    $self->session( User_last_name => $user->last_name );
    $self->session( User_type => $user->type );

    warn $user->email." logged in\n";

    #and return user type
    return $user->type;
}

sub logout{
    my $self = shift;
    
    warn $self->session( 'User_email' )." logged out\n";
    
    $self->session( User_id => 0 );
    $self->session( User_email => undef );
    $self->session( User_first_name => undef );
    $self->session( User_last_name => undef );
    $self->session( User_type => undef );
            
    $self->redirect_to( '/users/home' );
}

sub check {
    my $self = shift;
    
    #retrieve user stored in session
    my $user = $self->db->resultset( 'User' )->find( $self->session( 'User_id' ) );
    my $type = $self->param( 'type' );
    
    #user is valid
    if ( $user && ($user->email eq $self->session( 'User_email' ) ) ) {
        #type is required and user is that type
        if ( $type && $user->type eq $type ) {
            #return true value
            1;   
        }#type is not required
        elsif ( !$type ) {
            #return true value
            1;
        }
        elsif ( $type && $user->type ne $type ) {
            #redirect to login page
            $self->redirect_to( '/login' );
        }
    } #user is invalid
    else {
        #redirect to login page
        $self->redirect_to( '/login' );
        0;
    }
}

sub delete {
    my $self = shift;

    #delete the user with given id
    $self->db->resultset( 'User' )->find( $self->param( 'id' ) )->delete();

    #and redirect to users page
    $self->redirect_to( '/users/all' );
}

1;
