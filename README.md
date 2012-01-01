# WASTE is a Wget based Automatic Stress TEsting tool. 

WASTE is a fairly simple bash script that evolved from just forking wget instances in background. Although it is not the most efficient approach, Wget is very light and any modern system can easily spawn hundreds of instances without much effort.

There are many free and open source tools that can be used to generate load on a website. ApacheBench, Siege, JMeter, etc. Some of them are very flexible and sophisticated, some of them, too much.

This script interprets a simulation script file, this simulation script contains the commands to be excecuted in order, such as POST, GET, WAIT, and EXPECT, this last one is used to test the HTTP response data for a specific condition, for example, to test that it contains certain string or fail otherwise. 

The time required to complete each request is registered in milliseconds using GNU time, along with a final accumulated waiting time for the session.

EXPECT conditions can be customized as separated scripts or programs that take the HTTP data from the standard input and return 0 if the condition is met.

A launch.sh script that launches N simulation sessions in the background is provided.

Be aware that a system wide limitation for process forking may be in place in your system. It is generally set in /etc/security/limits.conf, refered as nprocs. Your mileage may vary.
