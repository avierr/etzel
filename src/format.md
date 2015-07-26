###Subscribe

{
"cmd":"SUB",
"qname": "xyz"
}


###Publish

{
"cmd":"PUB",
"qname": "xyz",
"message": "your message"
}


Algo for worker:

AWAKE_MODE:

    1. Req for job
    2. if no job go to SLEEP_MODE
    3. Process the Job.
    4. Go to Step 1.
    
SLEEP MODE:

    1. Listen to Socket
        - If Data.job==AVBL go to AWAKE_MODE
 
 
Algo for Server:

ON_SUBSCRIBE:
    - Attach PID to the Q.
    
ON_PUBLISH:
    - Broadcast Awake Signal to all processes in the Q.    

ON_JOB_REQUEST
    - Pop the top of the Queue & Send it to the requested Client      
