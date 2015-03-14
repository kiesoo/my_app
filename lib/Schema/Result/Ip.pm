use utf8;
package Schema::Result::Ip;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("Ips");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "ip_addr",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("UQ__Ips__C734061315506B43", ["ip_addr"]);
__PACKAGE__->has_many(
  "browser_ips",
  "Schema::Result::BrowserIp",
  { "foreign.id_ip" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "os_ips",
  "Schema::Result::OsIp",
  { "foreign.id_ip" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "page_ips",
  "Schema::Result::PageIp",
  { "foreign.id_ip" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-08-31 21:48:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zzZduvk9U2mRecP8VQVQWA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
