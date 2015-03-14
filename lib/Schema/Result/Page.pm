use utf8;
package Schema::Result::Page;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("Pages");
__PACKAGE__->add_columns(
  "page",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "page_ips",
  "Schema::Result::PageIp",
  { "foreign.id_pg" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-08-31 21:48:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:15aYm1TKgd1LQ9V2cU6iqw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
