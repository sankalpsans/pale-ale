# pale-ale
Pale ALE, or Plain And LEan AWS Log-analyzer for ElasticLoadBalancer (that was really stretching it, wasn't it?) is a lean and simple utility written in bash which I use every now and then to see what's happening with my load balancer at about right now. As of now, it supports basic commands to get the most elementary info, and is not fit for processing warehoused data for insight over years.

# Why?
It was needed. I could have used something like logtash, but it's not as lean in terms of installation, usage, maintenance, etc. Pale Ale is built in bash, which every programmer almost always has (and now [even the Windows ones will have it](http://techcrunch.com/2016/03/30/be-very-afraid-hell-has-frozen-over-bash-is-coming-to-windows-10/)). Plus it was fun, and hardly took 10 minutes. It is immensely useful to me on a daily basis.

# Installation
You need to basically copy the tiny little functions and variables in your `.bashrc` to be able to use them (and modify the variable as per your need). That's it for installation.

If you're looking for the traditional step-by-step guide, here it is:

* Clone
* Replace the parameters `BUCKET`, `LOGPATH` mentioned at the top of the file `bash_append.bash` to suit you.
* `cat bashrc_append.bash >> ~/.bashrc` Appending the defined functions
* `cd ~`
* `. ./.bash_rc`

# Usage
If you have log file locally instead of on an S3 bucket, you can skip steps 1 and 2.
1. `showlogs` lists all the log files that have been generated for today's calendar date as shown below.

![Image:List of log files for today, sorted as provided by S3](https://sankalpinspiration.files.wordpress.com/2016/04/screen-shot-2016-04-01-at-9-07-01-am.png "List of log files for today, sorted as provided by S3")

2. Choose the file you want to analyze by using `getlog [filename]`. This will download the file in your current directory

![Image:Download the log file from S3 to local](https://sankalpinspiration.files.wordpress.com/2016/04/screen-shot-2016-04-01-at-9-15-44-am.png "Download the log file from S3 to local")

Alternatively, you can bulk download files for particular timestamps using the newly added command `getlogs`

`getlogs 2018-08-19 00:10 2018-08-19 00:30` will get you log files between the two timestamps passed here (UTC).

3. The fun begins! Use all sorts of commands (sigh, there are only three as of now) on this file to see "what's happening" (read that in Gary Cole voice from the movie Office Space) with your Elastic Load Balancer today!


# List of commands
* `find4xx [filename]` (literally type "4xx", not "404", not "400", but "4xx") lists 4xx status codes from the log file in question.
* `find5xx [filename]` (again, literal "5xx") lists 5xx status codes from the log file provided.
* `findslow [filename]` lists the requests which took the most amount of time from the log file.
