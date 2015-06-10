Ruppells Sockets Client Helper
==============================

What is it?
-----------

A bash script that will connect to Ruppells Sockets and run the specified command in the Socket environment, exiting when either the socket or the command exits.

How do I run it?
----------------

Assuming your RUPPELLS_SOCKETS_FRONTEND_URI and RUPPELLS_SOCKETS_TUNNEL_URI environment variables are set and you'd like to run nc, like this:

    rs-conn $(nc -kl 1337)

By default rs-conn will connect a local socket listening on the port set in the RUPPELLS_SOCKETS_LOCAL_PORT environment variable to the Ruppells Sockets frontent URI allocated to your app.

If you'd like something a little more fancy check the -h CLI option.

If you'd like something a lot more fancy, fork, change and send me a pull request :)
