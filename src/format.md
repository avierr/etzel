

### Subscribe to queue

```
{
    "cmd":"SUB",
    "qname": "$Q_NAME"
}
```

### Fetch a message from Queue

```
{
    "cmd":"FET",
    "qname": "$Q_NAME"
}
```

### Publish

````
{
    "cmd":"PUB",
    "qname": "$Q_NAME",
    "message": "$message",
}
````
**Optional messages' parameters:**

* `timeout`: After timeout (in seconds), item will be placed back onto queue.
You must delete the message from the queue to ensure it does not go back onto the queue.
 Default is 60 seconds. Minimum is 5 seconds.

* `delay`: The item will not be available on the queue until this many seconds have passed.
Default is 0 seconds. Maximum is 365 days(in seconds).

* `expires`: How long in seconds to keep the item on the queue before it is deleted.
Default is infinity.


### inform server that you are going to SLEEP

````
{
    "cmd":"ISLP",
    "qname": "$Q_NAME"
}
````

--------------------------------
## Response From server:


### No Queue Found

````
{
    "cmd":"nok",
    "err": "Q_NOT_FOUND"
}
````

### No Message Available in the requested Queue

````
{
    "cmd":"nomsg",
    "qname": "$Q_NAME"
}
````

### It is ok to go to sleep

````
{
    "cmd":"okslp",
    "qname": "$Q_NAME"
}
````

### Message Available in the requested Queue

````
{
    "cmd": "msg",
    "qname": "$Q_NAME",
    "uid": "$uid",
    "error_count": "$count",
    "msg": "$message"
}
````

### Wake up the client for a particular Queue

````
{
    "cmd":"awk",
    "qname": "$Q_NAME"
}
````

### Algo for worker:

#### AWAKE_MODE:

    1. Req for job
    2. if no job go to SLEEP_MODE
    3. Process the Job.
    4. Go to Step 1.
    
#### SLEEP MODE:

    1. Listen to Socket
        - If job==AVBL go to AWAKE_MODE
 
 
### Algo for Server:

###### ON_SUBSCRIBE:
   - Spawn a process for client & attach its PID to the group.
   - Example: join_group(Qname,PID) 
    
    
###### ON_PUBLISH:
   - IF NO DELAY -> CALL PUBLISH();
   - Else: 
     - CALL PUBLISH(); with delay
     - write this info(key:value) to disk
````
PUBLISH()
   - Broadcast Awake Signal to all processes in the sleep list.
   - & Remove those processes from the sleep list.
   - Spawn a process for the Queue-X if it does not exist
   - & send the Element to this process.
   - Now this Queue-X Process will accept the element
   - & also write(async) the data to disk by generating required key:value  
````
###### ON_FET_REQUEST:

   1. Pop the top of the Queue 
   2. if the element matches with any element in the delete list: 
      2.1. remove the element from the delete list.
      2.2. Go to Step 1
   3. else Send it to the requested Client 
   4. increment the 'status' of the Element on Disk
   5. CALL PUBLISH(element) WITH DELAY:60

###### ON_ACK/DEL_REQUEST:

  - Delete the element from disk
  - PUSH the element to the delete list

### Queue format on disk
The queue elements are stored in a key value store in the following format.
````
1. DATA

let us divide DATA which is made up of a key and value.

2. Key: Value

divide them further

3. Qname-uid:  Status|Delay|expires|Item

Qname: Variable length text
Uid: 14-18 bytes
Status: 8 bits (Basically the error count)
Timeout: 64 bits 
delay: 64 bits
expires: 64 bits
Item: Variable lenght text

````
