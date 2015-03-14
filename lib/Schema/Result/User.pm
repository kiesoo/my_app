use utf8;
package Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", is_auto_increment => 1, is_nullable => 0 },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "genre",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "type",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "active",
  { data_type => "tinyint", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-08-31 21:48:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:N5LHQe1pna+8A7Snjx/S1A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
