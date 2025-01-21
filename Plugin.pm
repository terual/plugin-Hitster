# Lyrionster
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

package Plugins::Lyrionster::Plugin;

use base qw(Slim::Plugin::Base);

use strict;
use Slim::Utils::Strings qw (string);
use Slim::Utils::Log;
use Slim::Web::Pages;
use Slim::Player::Client;

my $log = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.Lyrionster',
	'defaultLevel' => 'INFO',
	'description'  => 'PLUGIN_LYRIONSTER',
});


sub initPlugin {
	my $class = shift;
	
	$class->SUPER::initPlugin();
}

sub getDisplayName() {
	return 'PLUGIN_LYRIONSTER';
}

sub webPages {
	Slim::Web::Pages->addPageFunction("plugins/Lyrionster/index.html", \&handleWeb);
	Slim::Web::Pages->addPageLinks("plugins", { 'PLUGIN_LYRIONSTER' => 'plugins/Lyrionster/index.html' });
	Slim::Web::Pages->addPageLinks('icons',   { 'PLUGIN_LYRIONSTER' => 'html/images/years.png' });
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
	$log->info( "player_chooser_list: " . Data::Dump::dump($params->{'player_chooser_list'}) );
	$log->info( "playercount: " . Data::Dump::dump($params->{'playercount'}) );
	
	if ($params->{'track'}) {
		if (defined $client) {
			$client->execute([ 'playlist', 'clear' ]);
			$client->execute([ 'playlist', 'play', $params->{'track'} ]);
			$log->info("Playlist play: $params->{'track'} on client " . $client->macaddress);
		} else {
			$log->info("No client");
		}
	}
	
	if ($params->{'pause'}) {
		if (defined $client) {
			$log->info("Execute pause on client " . $client->macaddress);
			$client->execute([ 'pause' ]);
		} else {
			$log->info("No client to pause");
		}
	}

	return Slim::Web::HTTP::filltemplatefile('plugins/Lyrionster/index.html', $params);
}


1;
