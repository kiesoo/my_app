use utf8;
package Schema::Result::BrowserIp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("Browser_IP");
__PACKAGE__->add_columns(
  "id_ip",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "id_br",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "data",
  { data_type => "datetime", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id_br", "id_ip", "data");
__PACKAGE__->belongs_to(
  "id_br",
  "Schema::Result::Browser",
  { id => "id_br" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "id_ip",
  "Schema::Result::Ip",
  { id => "id_ip" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-08-31 21:48:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IvIxCBMpxi5nJq+75MlC1A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
