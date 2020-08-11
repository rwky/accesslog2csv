#!/usr/bin/perl
use strict;
use warnings;
 
#
# @file
# Converter tool, from Nginx Access Log file to CSV.
# Log format should be:
#    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
#                      '$status $body_bytes_sent "$http_referer" '
#                      '"$http_user_agent" "$http_x_forwarded_for" '
#                      '$request_time $upstream_response_time';
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#   Copyright 2012 Woosan https://github.com/woonsan and Harald Albers https://github.com/albers
#   Copyright 2020 Rowan Wookey <admin@rwky.net>
#
 
if (defined $ARGV[0] && "$ARGV[0]" =~ /^-h|--help$/) {
  print "Usage: $0 access_log_file > csv_output_file.csv\n";
  print "   Or, $0 < access_log_file > csv_output_file.csv\n";
  print "   Or, $0 < access_log_file > csv_output_file.csv 2> invalid_lines.txt\n";
  exit(0);
}
 
my %MONTHS = ( 'Jan' => '01', 'Feb' => '02', 'Mar' => '03', 'Apr' => '04', 'May' => '05', 'Jun' => '06',
  'Jul' => '07', 'Aug' => '08', 'Sep' => '09', 'Oct' => '10', 'Nov' => '11', 'Dec' => '12' );
 
print STDOUT "\"Host\",\"Date Time\",\"Method\",\"Response Code\",\"Bytes Sent\",\"Request Time\",\"Upstream Response Time\",\"URL\",\"Referer\",\"User Agent\"\,\"X-Forwarded-For\"\r\n";
my $line_no = 0;
my $invalid = 0;
 
while (<>) {
  ++$line_no;
  if (/^([\w\.:-]+) - [\w\.:-]+\s+\[(\d+)\/(\w+)\/(\d+):(\d+):(\d+):(\d+)\s?[\w:\+-]+\]\s+"(\w+)\s+(\S+)\s+HTTP\/\d\.\d"\s+(\d+)\s+([\d-]+)(?:(?:\s+"([^"]*?)"\s+")?([^"]*?)")?\s+"([\w\.:,\s-]+)"\s+(\d+\.\d+)\s+([\d\.-]+)$/) {
    my $host = $1;
    my $day = $2;
    my $month = $MONTHS{$3};
    my $year = $4;
    my $hour = $5;
    my $min = $6;
    my $sec = $7;
    my $method = $8;
    my $url = $9;
    my $code = $10;
    my $bytesd;
    if ($11 eq '-') {
      $bytesd = 0;
    } else {
      $bytesd = $11;
    }
    my $referer = $12;
    my $ua = $13;
    my $xforwarded = $14;
    my $time = $15;
    my $upstream;
    if ($16 eq '-') {
	    $upstream = 0;
    } else {
    	$upstream = $16;
    }
    print STDOUT "\"$host\",\"$year-$month-$day $hour:$min:$sec\",\"$method\",$code,$bytesd,$time,$upstream,\"$url\",\"$referer\",\"$ua\",\"$xforwarded\"\r\n";
  } else {
	  ++$invalid;
    print STDERR "Invalid Line at $line_no: $_";
  }
}
print STDERR "$line_no lines processed, $invalid invalid\n";
