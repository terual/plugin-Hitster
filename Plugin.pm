# Hitster
# Copyright (C) 2025
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package Plugins::Hitster::Plugin;

use base qw(Slim::Plugin::Base);

use strict;
use Slim::Utils::Strings qw (string);
use Slim::Utils::Log;
use Slim::Web::Pages;
use Slim::Player::Client;

my $log = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.Hitster',
	'defaultLevel' => 'INFO',
	'description'  => 'PLUGIN_HITSTER',
});


sub initPlugin {
	my $class = shift;
	
	$class->SUPER::initPlugin();
}

sub getDisplayName() {
	return 'PLUGIN_HITSTER';
}

sub webPages {
	Slim::Web::Pages->addPageFunction("plugins/Hitster/index.html", \&handleWeb);
	Slim::Web::Pages->addPageLinks("plugins", { 'PLUGIN_HITSTER' => 'plugins/Hitster/index.html' });
	Slim::Web::Pages->addPageLinks('icons',   { 'PLUGIN_HITSTER' => 'html/images/years.png' });
}

sub handleWeb {
	my ($client, $params) = @_;
	
	$params->{'playercount'} = Slim::Player::Client::clientCount();
	my @players = Slim::Player::Client::clients();
	if (scalar(@players) >= 1) {
		my %clientlist = ();
		for my $eachclient (@players) {
			$clientlist{$eachclient->id()} =  $eachclient->name();
			if ($eachclient->isSynced()) {
				$clientlist{$eachclient->id()} .= " (" . string('SYNCHRONIZED_WITH') . " " .
					$eachclient->syncedWithNames() .")";
			}
		}
		$params->{'player_chooser_list'} = Slim::Web::Pages::Common->options($client->id(), \%clientlist, $params->{'skinOverride'}, 50);
	}
	$log->debug( "player_chooser_list: " . Data::Dump::dump($params->{'player_chooser_list'}) );
	$log->debug( "playercount: " . Data::Dump::dump($params->{'playercount'}) );
	
	if ($params->{'track'}) {
		if (defined $client) {
			$client->execute([ 'playlist', 'clear' ]);
			$client->execute([ 'playlist', 'play', $params->{'track'} ]);
			$log->debug("Playlist play: $params->{'track'} on client " . $client->macaddress);
		} else {
			$log->debug("No client");
		}
	}
	
	if ($params->{'pause'}) {
		if (defined $client) {
			$log->debug("Execute pause on client " . $client->macaddress);
			$client->execute([ 'pause' ]);
		} else {
			$log->debug("No client to pause");
		}
	}

	return Slim::Web::HTTP::filltemplatefile('plugins/Hitster/index.html', $params);
}


1;
