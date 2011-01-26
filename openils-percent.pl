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
my $config_file = '/openils/conf/opensrf.xml';

    # get info from XML conf file
    my $parser = XML::LibXML->new();

    my $config = $parser->parse_file($config_file);

    my $node = $config->findnodes('/opensrf/default/apps/' . $app);

    my $max_kids = $node->[0]->findvalue('unix_config/max_children');

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
       my $dcount = $service_data{drone} || 0;

if (exists $ARGV[0]) {
	if ($ARGV[0] eq 'config'){
	   my $max;
	   my $warning = 70;
	   my $critical = 85;
	   print "graph_args --lower-limit 0 --upper-limit 100\n";
	   print "graph_category OpenSRF\n";
	   print "graph_info Shows $app workers as a percentage of max_children\n";
	   print "graph_scale percent\n";
	   print "graph_title Percent of $app drones used\n";
	   print "graph_vlabel Percent drone usage\n";
	   print "drones.label Drone Usage\n";
	   print "drones.type GAUGE\n";
	   print "drones.draw LINE\n";
	   print "drones.warning $warning\n";
	   print "drones.critical $critical\n";
	   print "drones.info Drone Usage\n";
	}
}

my $dronepercent = $dcount / $max_kids * 100;

print "drones.value $dronepercent";


