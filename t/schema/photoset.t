use Modern::Perl;
use Test::More;
use Schema;
use Test::Database;

my $schema = Test::Database->new->create(Schema => ':memory:');

my $photoset_id      = '72157624222825789';
my $photoset_title   = 'robot_arms';
my $prev_photoset_id = '72157624222820921';
my $next_photoset_id = '72157624347519408';

is $schema->resultset('Photoset')->by_id_or_name($photoset_id)->id =>
  $photoset_id;
is $schema->resultset('Photoset')->by_id_or_name($photoset_title)->id =>
  $photoset_id;

my $set = $schema->resultset('Photoset')->find($photoset_id);

is ref $set->date         => 'DateTime';
is $set->date->month_abbr => 'Jun';
is $set->date->year       => 2010;

is $set->primary->id => $set->primary_photo->id, 'primary photo alias';
is $set->region      => 'California';
is $set->url_title   => $photoset_title;
is $set->location    => 'Chico, California';
like $set->time_since => qr/\d+ \w+ and \d+ \w+ ago/;

is $set->previous->id => $prev_photoset_id, 'previous photoset';
is $set->next->id     => $next_photoset_id, 'next photoset';

like $set->time_since => qr/\d+ \w+ and \d+ \w+ ago/, 'time since';

done_testing;
