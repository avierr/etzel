###Subscribe to queue

```
{
    "cmd":"SUB",
    "qname": "$Q_NAME"
}
```

###Fetch a message from Queue

```
{
    "cmd":"FET",
    "qname": "$Q_NAME"
}
```

###Publish

````
{
    "cmd":"PUB",
    "qname": "$Q_NAME",
    "message": "$message"
}
````

###inform server that you are going to SLEEP

````
{
    "cmd":"ISLP",
    "qname": "$Q_NAME"
}
````

--------------------------------
##Response From server:


###No Queue Found

````
{
    "cmd":"nok",
    "err": "Q_NOT_FOUND"
}
````

###No Message Available in the requested Queue

````
{
    "cmd":"nomsg",
    "qname": "$Q_NAME"
}
````

###Message Available in the requested Queue

````
{
    "cmd":"msg",
    "qname": "$Q_NAME",
    "msg": "$message"
}
````

###Wake up the client for a particular Queue

````
{
    "cmd":"AWK",
    "qname": "$Q_NAME"
}
````

###Algo for worker:

####AWAKE_MODE:

    1. Req for job
    2. if no job go to SLEEP_MODE
    3. Process the Job.
    4. Go to Step 1.
    
####SLEEP MODE:

    1. Listen to Socket
        - If job==AVBL go to AWAKE_MODE
 
 
###Algo for Server:

ON_SUBSCRIBE:
    - Attach PID to the Q.
    
ON_PUBLISH:
    - Broadcast Awake Signal to all processes in the "__SLPL" sleep list .    

ON_JOB_REQUEST
    - Pop the top of the Queue & Send it to the requested Client      
