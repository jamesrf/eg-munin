#!/usr/bin/perl
#
# Plugin to monitor OpenILS Applications
#
# Author:
#    James Fournie <james.fournie@gmail.com>
#
# Created:
#    18 Dec 2009
#
# Usage:
#    symlink to the file as:
#       - openils_storage to monitor open-ils.storage
#       - openils_actor to monitor open-ils.actor
#       etc.
#
# Parameters:
#    config
#
use XML::LibXML;
use Getopt::Long;
use Data::Dumper;

my $app = $0;
$app =~ s/_/./;
$app =~ s/openils/open\-ils/g;
$app =~ s/(.+)\///g;
my $config_file = exists $ENV{'configfile'} ? $ENV{'configfile'} : '/openils/conf/opensrf.xml';

# get info from XML conf file
my $parser = XML::LibXML->new();

my $config = $parser->parse_file($config_file);

my $node = $config->findnodes('/opensrf/default/apps/' . $app);

my $maxchildren = $node->[0]->findvalue('unix_config/max_children') || 0;
my $minchildren = $node->[0]->findvalue('unix_config/min_children') || 0;
my $minsparechildren = $node->[0]->findvalue('unix_config/min_spare_children') || 0;
my $maxsparechildren = $node->[0]->findvalue('unix_config/max_spare_children') || 0;

my $listenercount = $service_data{listener} || 0;

my @data = split /\n/s, `ps ax|grep OpenSRF`;

my %service_data;
for (@data) {
    if (/OpenSRF (\w+) \[([^\]]+)\]/) {
        my ($s,$t) = ($2,lc($1));
        next unless $s eq $app;
        if (!exists($service_data{$t})) {
            $service_data{$t} = 1;
        } else {
            $service_data{$t}++
        }
    }
} 

my $dronecount = $service_data{drone} || 0;
my $listenercount = $service_data{listener} || 0;
my $controllercount = $service_data{controller} || 0;

if (exists $ARGV[0]) {
	if ($ARGV[0] eq 'config'){
	   my $max;
	   my $warning = $max*75/100;
	   my $critical = $max*90/100;
	   print "graph_args --lower-limit 0\n";
	   print "graph_category OpenSRF\n";
	   print "graph_info Shows $app workers\n";
	   print "graph_scale nodes\n";
	   print "graph_title Drones for $app\n";
	   print "drones.label Drones\n";
	   print "drones.type GAUGE\n";
	   print "maxchildren.type GAUGE\n";
       print "maxchildren.label Max Children\n";
       print "maxchildren.draw LINE2\n";
       print "maxchildren.colour FF0000\n";
	   #print "listeners.type GAUGE\n";
	  # print "controllers.type GAUGE\n";
	  # print "minchildren.type GAUGE\n";
	  # print "maxsparechildren.type GAUGE\n";
	   #print "minsparechildren.type GAUGE\n";
       
       print "drones.colour 00FF00\n";
	   print "drones.draw LINE\n";
	}
}

print "listeners.value $listenercount\n";
print "controllers.value $controllercount\n";
print "maxsparechildren.value $maxsparechildren\n";
print "minsparechildren.value $minsparechildren\n";
print "maxchildren.value $maxchildren\n";
print "minchildren.value $minchildren\n";
print "drones.value $dronecount\n";

exit(0);
