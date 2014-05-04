# Copyright (c) 2010 by Barry Arthur <barry.arthur@gmail.com>:
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# Color disliked nicks to dissuade communication with reprobates.
#
# History:
# 2014-05-04, bairui <barry.arthur@gmail.com>:
#     version 0.1: initial release
#

use strict;

my $version = "0.1";

# default values in setup file (~/.weechat/plugins.conf)
my %default_badnick = ('bad_color' => "red", 'bad_nicks' => "");

foreach my $key (keys %default_badnick) {
  weechat::config_set_plugin($key, $default_badnick{$key}) if (weechat::config_get_plugin($key) eq "");
}

# colorize_input_cb(data, modifier, modifier_data, line)
sub colorize_input_cb {
  my $bad_color = weechat::color(weechat::config_get_plugin("bad_color"));
  my $bad_nicks = weechat::config_get_plugin("bad_nicks");
  my $reset     = weechat::color('reset');
  my $line      = $_[3];
  foreach my $nick (split(/\s*,\s*/, $bad_nicks)) {
    $line =~ s/$nick/${bad_color}${nick}${reset}/;
  }
  $line;
}

weechat::register("badnick", "bairui <barry.arthur\@gmail.com>", $version,
                  "GPL3", "Show bad nicks in red", "", "");

weechat::hook_modifier('250|input_text_display', 'colorize_input_cb', '')
