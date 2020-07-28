accesslog2csv
=============

Utility script converting Nginx log files to CSV format files

```
Log format should be:
   log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                     '$status $body_bytes_sent "$http_referer" '
                     '"$http_user_agent" "$http_x_forwarded_for" '
                     '$request_time $upstream_response_time';
```

How to run
----------

```
$ perl accesslog2csv.pl access_log_file > csv_output_file.csv
```

Or, you can redirect STDIN like the following examples:

```
$ perl accesslog2csv.pl < access_log_file > csv_output_file.csv
```

```
$ cat access_log_file | perl accesslog2csv.pl > csv_output_file.csv
```

Also, you can check invalid log lines by redirecting STDERR, too:

```
$ perl accesslog2csv.pl < access_log_file > csv_output_file.csv 2> invalid_log_lines.txt
```

Hope it helps somewhere! :-)
