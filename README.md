This is a simple service, built on top of our 
[simple-queue-server](https://github.com/medusa-project/simple-queue-server) gem.

The server configures a lot of storage endpoints. Clients who wish to copy content from one storage 
endpoint to another send the server a message and it does it. (It may seem overkill to have a 
separate service to do this, but our particular system topology argues for it.) Rclone is used
in order to take advantage of its ability to handle various storage types.

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
for the basic request format.

copyto action:

This action essentially executes 'rclone copyto source_root:source_key target_root:target_key' 

- Incoming parameters:

  - source root
  - source key
  - target root
  - target key
  
And: 

- Outgoing parameters:

  In any case, assuming the message was parseable and had all the needed incoming parameters, they are
  returned. Also rclone_status will be returned with the rclone exit status, if available. 
  
  If there is an error then some sort of error message is returned in 'message', possibly with additional
  information in the parameters when I determine them.