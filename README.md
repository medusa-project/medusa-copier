Overview
========

This is a simple service, built on top of our 
[simple-queue-server](https://github.com/medusa-project/simple-queue-server) gem.

The server configures a lot of storage endpoints. Clients who wish to copy content from one storage 
endpoint to another send the server a message and it does it. (It may seem overkill to have a 
separate service to do this, but our particular system topology argues for it.) Rclone is used
in order to take advantage of its ability to handle various storage types.

Rclone's full capabilities aren't being used in a single-copy mode, but more than once of these
can be run in order to make things more parallel. If we do develop a full 'copy' mode, then 
we should be able to use rclone more fully.

Configuration
=============

config/medusa_copier.yaml contains the message server configuration and information about the roots. This
file essentially enables the messaging configuration and mapping between arbitrary root names and
rclone configs.

Rclone must also be configured to be able to use the storage at the desired endpoints, which must
of course be available on the machine running this server. Rclone is responsible for things like S3
connectivity.

Running
=======

The medusa_copier.sh script can be used to start and stop the server. There is also a toggle-halt
command that will let the server finish the request it is working on and then halt (or if used again go cancel this
behavior). This works by sending USR2 to the server, so you can do that manually as well.

Requests
========

See the [simple-queue-server](https://github.com/medusa-project/simple-queue-server)
for the basic request format. As always, you should put enough identifying information 
into the pass through.

copyto action:

This action essentially executes 'rclone copyto source_root:source_key target_root:target_key' 

- Incoming parameters:

  - source root
  - source key
  - target root
  - target key

- Outgoing parameters:

  No outgoing parameters are currently specified to be returned.
  
  rclone_status will be returned with the rclone exit status code, if available, at the top level.
  
  If there is an error then some sort of error message is returned in 'message', possibly with additional
  information.
  
Future Directions
=================

* Possibly add 'copy' command to handle directory copies.
* Possibly use rclone rcd/rc instead of spawning new rclones all the time, although for our
  use doing the latter is not likely to be a big deal. It's possible that we might be able
  to do better error handling that way, though. I haven't explored it very much yet.
* Possibly make the rclone config file configurable
* Possibly include a copy of rclone to be used so everything is self contained
* Possibly containerize
  