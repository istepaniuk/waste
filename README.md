# WASTE - Wget based Automatic Stress TEsting tool 

## Description
Working at [SaludOnNet](http://www.saludonnet.com/), we needed a way to send specifically crafted requests to our JSON-RPC Backend and test the responses. We started playing arround with wget in the console, but finally got to write a script to do the job for us.

WASTE is a fairly simple bash script that evolved from just forking wget instances in background. Although it is not the most efficient approach, wget is very light and any modern system can easily spawn hundreds of instances without much effort.

There are many free and open source tools that can be used to generate load on a website. ApacheBench, Siege, JMeter, etc. Some of them are very flexible and sophisticated, some of them, too much.

This script interprets a simulation script file, this simulation script contains the commands to be excecuted in order, such as POST, GET, WAIT, and EXPECT, this last one is used to test the HTTP response data for a specific condition, for example, to test that it contains certain string or fail otherwise. 

The time required to complete each request is registered in milliseconds using GNU time, along with a final accumulated waiting time for the session.

A launch.sh script that launches N simulation sessions in the background is provided.

Be aware that a system wide limitation for process forking may be in place in your system. It is generally set in `/etc/security/limits.conf`, refered as nproc. Your mileage may vary.

## Usage
To launch 200 parallel requests:

    $ ./launch.sh example.sim 200

TO launch just one you can also use:

    $ ./waste.sh example.sim

## Sim Script
    # Comments start with hash
 
    # GET takes one parameter, the url
    GET "/static/index.html"
   
    # POST takes two parameters, the url and the url-encoded post data
    POST "/controllers/validate" "id=14&action=confirm"

    # WAIT X, passes X seconds to the 'sleep' command
    WAIT 2
   
    POST "/controllers/validate" "id=12&action=confirm"
    
    # EXPECT go after a request and executes a matcher by that name in the ./matchers dir
    EXPECT it to contain \"result\":\"success\"
    
    GET "/static/confirm.php?action=delete"
    EXPECT that it contains main_content
   
    WAIT 1 
   
    POST "/controllers/delete" "id=12"
    EXPECT that contains wasValid\":true

## Matchers
EXPECT conditions can be customized as separated scripts or programs that take the HTTP data from the standard input and return 0 if the condition is met.

* `equals` and `contains` are included along with `not`, this last one simply negates the following matcher command status.
* `that`, `it`, `does` and `to` are permitted and do not change the behavior, their function is to allow you to write your conditions in plain english. ie: `EXPECT that it does not contain "error"` or `EXPECT it to equal "apple"`.

## Output
The output consists in a line per POST, GET or EXPECT, containing the script PID, the COMMAND-Line Number: and the time in milliseconds that took the request. A final `CUMULATIVE` line is included with the sum for all the request time.

    25933:GET-3: 12
    25933:EXPECT-4: PASSED
    25933:POST-2: 202
    25933:EXPECT-3: PASSED
    25933:POST-4: 300
    25933:EXPECT-5: FAILED to contain "result":"success" ["result":"error","code":"312"]
    25933:GET-2: 310
    25933:EXPECT-3: PASSED
    25933:POST-4: 120
    25933:EXPECT-5: PASSED
    25933:CUMULATIVE: 944
    
When an EXPECT fails, the condition is printed followed by the actual response data inside square brakets.    

## Aknowledgements
* Hrvoje Nikšić and Giuseppe Scrivano for the great [GNU Wget](http://www.gnu.org/software/wget/)
* Carlos Blé (@carlosble) for his infinite patience while debugging together our web application.