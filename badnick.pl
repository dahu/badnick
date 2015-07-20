# Copyright (c) 2014 by Barry Arthur <barry.arthur@gmail.com>:
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
# 2015-07-20, bairui <barry.arthur@gmail.com>:
#     version 0.3: added "badnick" tag to users' contributions (from Raimondi's naughty plugin)
# 2014-05-10, bairui <barry.arthur@gmail.com>:
#     version 0.2: fixed uninitialized script error
# 2014-05-04, bairui <barry.arthur@gmail.com>:
#     version 0.1: initial release
#

use strict;

my $version = '0.3';

weechat::register('badnick', "bairui <barry.arthur\@gmail.com>", $version, 'GPL3', 'Show bad nicks', '', '');

weechat::hook_modifier('250|input_text_display' , 'colorize_input_cb'   , '');
weechat::hook_modifier('irc_in_privmsg'         , 'badnick_cb'          , '');
weechat::hook_modifier('weechat_print'          , 'colorize_print_cb'   , '');

# default values in setup file (~/.weechat/plugins.conf)
my %default_badnick = ('bad_color' => 'red', 'bad_nicks' => '');

foreach my $key (keys %default_badnick) {
  weechat::config_set_plugin($key, $default_badnick{$key}) unless weechat::config_is_set_plugin($key);
}

# colorize_input_cb(data, modifier, modifier_data, line)
sub colorize_input_cb {
  my $bad_color = weechat::color(weechat::config_get_plugin('bad_color'));
  my @bad_nicks = split(/\s*,\s*/, weechat::config_get_plugin('bad_nicks'));
  my $reset     = weechat::color('reset');
  my $line      = $_[3];

  foreach my $nick (@bad_nicks) {
    $line =~ s/$nick/${bad_color}${nick}${reset}/;
  }
  $line;
}

sub badnick_cb {
  my $bad_color  = weechat::color(weechat::config_get_plugin('bad_color'));
  my @bad_nicks  = split(/\s*,\s*/, weechat::config_get_plugin('bad_nicks'));
  my $reset      = weechat::color('reset');
  my $string     = $_[3];
  my $new_string = $string;
  my $msg        = weechat::info_get_hashtable("irc_message_parse" => { "message" => $string });
  my $args       = $msg->{arguments};

  $args          =~ s/^$msg->{channel}/$msg->{channel} :<naughty_marker>/;
  $args          =~ s/(<naughty_marker>).:(\x01ACTION)/$2 $1/;
  $new_string    =~ s/\Q$msg->{arguments}\E$/$args/;
  return (grep {$_ eq $msg->{nick}} @bad_nicks) ? $new_string : $string;
  # return $new_string if grep {$_ eq $msg->{nick}} @bad_nicks;
  # $string;
}

sub colorize_print_cb {
  my $bad_color = weechat::color(weechat::config_get_plugin('bad_color'));
  my $reset     = weechat::color('reset');
  my $line      = $_[3];

  $line =~ s/<naughty_marker>(( ):?)?/${bad_color}badnick${reset}$2/;
  $line;
}
