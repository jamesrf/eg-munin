#!/usr/bin/perl
#
# Plugin to monitor all OpenILS Applications
#
# Author:
#    James Fournie <james.fournie@gmail.com>
#
# Created:
#    18 Dec 2009
#
# Usage:
#    symlink to /etc/munin/plugins/whatever
#       etc.
#
# Parameters:
#    config
#
use XML::LibXML;
use Getopt::Long;
use Data::Dumper;


my $config_file = exists $ENV{'configfile'} ? $ENV{'configfile'} : '/openils/conf/opensrf.xml';

    # get info from XML conf file
    my $parser = XML::LibXML->new();

    my $config = $parser->parse_file($config_file);

    my @apps = $config->findnodes('/opensrf/default/apps/*');


 	@$services = map { $_->nodeName } @apps;

        my @data = split /\n/s, `ps ax|grep OpenSRF`;
        my %service_data;
        for (@data) {
            if (/OpenSRF (\w+) \[([^\]]+)\]/) {
                my ($s,$t) = ($2,lc($1));
                next unless (grep { $s eq $_ } @$services);
                if (!exists($service_data{$s}{$t})) {
                    $service_data{$s}{$t} = 1;
                } else {
                    $service_data{$s}{$t}++
                }
            }
        }
   

if (exists $ARGV[0]) {
	if ($ARGV[0] eq 'config'){
	   my $max;
	   my $warning = 70;
	   my $critical = 85;
	   print "graph_args --lower-limit 0 --upper-limit 100\n";
	   print "graph_category OpenSRF\n";
	   print "graph_info Shows percentage usage of drones\n";
	   print "graph_scale percent\n";
	   print "graph_title Percent Drone Usage\n";
	   print "graph_vlabel Percent drone usage\n";
	   foreach(@$services){
		$_ =~ s/\./_/g;
		$_ =~ s/-//g;
		#my $type = 'STACK';
		my $type = 'LINE';
		$_ eq $services->[0] ? $type = 'LINE' : print "\n";
		
		print $_ . ".label " . $_ . "\n";
		print $_ . ".type GAUGE\n";
		print $_ . ".draw $type";
	   }
	}
}
for my $s ( @$services ) {
    my ($node) = grep { $_->nodeName eq $s } @apps;
    next unless ($node);
    print "\n" unless $s eq $services->[0];
    my $max_kids = $node->findvalue('unix_config/max_children');
    my $imp_lang = $node->findvalue('language');

    my $lcount = $service_data{$s}{listener} || 0;
    my $dcount = $service_data{$s}{drone} || 0;
    my $mcount = $service_data{$s}{master} || 0;
    my $ccount = $service_data{$s}{controller} || 0;

    my $dronepercent = $dcount / $max_kids * 100;
    $s =~ s/-//g;
    $s =~ s/\./_/g;
    print $s . ".value " . $dronepercent . "\n";
}
exit(0);
