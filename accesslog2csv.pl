#!/usr/bin/perl
 
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
 
if ("$ARGV[0]" =~ /^-h|--help$/) {
  print "Usage: $0 access_log_file > csv_output_file.csv\n";
  print "   Or, $0 < access_log_file > csv_output_file.csv\n";
  print "   Or, $0 < access_log_file > csv_output_file.csv 2> invalid_lines.txt\n";
  exit(0);
}
 
%MONTHS = ( 'Jan' => '01', 'Feb' => '02', 'Mar' => '03', 'Apr' => '04', 'May' => '05', 'Jun' => '06',
  'Jul' => '07', 'Aug' => '08', 'Sep' => '09', 'Oct' => '10', 'Nov' => '11', 'Dec' => '12' );
 
print STDOUT "\"Host\",\"Date Time\",\"Method\",\"URL\",\"Response Code\",\"Bytes Sent\",\"Referer\",\"User Agent\"\,\"X-Forwarded-For\",\"Request Time\",\"Upstream Response Time\"\r\n";
$line_no = 0;
$invalid = 0;
 
while (<>) {
  ++$line_no;
  if (/^([\w\.:-]+) - [\w\.:-]+\s+\[(\d+)\/(\w+)\/(\d+):(\d+):(\d+):(\d+)\s?[\w:\+-]+\]\s+"(\w+)\s+(\S+)\s+HTTP\/\d\.\d"\s+(\d+)\s+([\d-]+)(?:(?:\s+"([^"]*?)"\s+")?([^"]*?)")?\s+"([\w\.:,\s-]+)"\s+(\d+\.\d+)\s+([\d\.-]+)$/) {
    $host = $1;
    $day = $2;
    $month = $MONTHS{$3};
    $year = $4;
    $hour = $5;
    $min = $6;
    $sec = $7;
    $method = $8;
    $url = $9;
    $code = $10;
    if ($11 eq '-') {
      $bytesd = 0;
    } else {
      $bytesd = $11;
    }
    $referer = $12;
    $ua = $13;
    $xforwarded = $14;
    $time = $15;
    if ($16 eq '-') {
	$upstream = 0;
    } else {
    	$upstream = $16;
    }
    print STDOUT "\"$host\",\"$year-$month-$day $hour:$min:$sec\",\"$method\",\"$url\",$code,$bytesd,\"$referer\",\"$ua\",\"$xforwarded\",\"$time\",\"$upstream\"\r\n";
  } else {
	  ++$invalid;
    print STDERR "Invalid Line at $line_no: $_";
  }
}
print STDERR "$line_no lines processed, $invalid invalid\n";
