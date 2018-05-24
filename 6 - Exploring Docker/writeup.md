# Chapter 6 - Exploring Docker

This chapter will explore the capabilities of our running Docker containers.

## Printing the Docker Version

The most basic operation we can perform with Docker is to print out the versions of the Docker client and server,
along with the versions of the components that they use; the command for this is `docker version`. This command
will talk to the remote Docker server in order to obtain its details, so this will not work if you are having
connectivity issues.

Since the Docker client and server were installed at the same time, the versions will match; if they did not, Docker
would not let the client talk to the server, even if the Docker API version were compatible with both.

## Server Information

The Docker client can also be used to retrieve information about the Docker server, such as which __filesystem
backend,__ which __kernel version__ it is on, which __operating system__ it is running on, and how many containers
and images it is currently storing.

Most installations of Docker will use /var/lib/docker as the server's root directory, where it will store images
and containers. This can be changed when starting the Docker daemon by adding a `--graph="/other/directory"` argument
to the startup script.

## Downloading Image Updates

When attempting to `pull` an image with the 'latest' tag, Docker will always check to see if the locally-stored 
version of that image (if any) is the most up-to-date version; if not, then it will pull it from the registry. This
is because 'latest' is a tag that is by convention reserved for the most recent version of that image that has been
pushed.

Pulling a more recent version of a locally-stored image will only pull down the layers of the image that have changed
since your version was created. Keep in mind that Docker will not automatically make sure your local images are
up-to-date; you'll have to be responsible for that yourself.

Docker 1.6 enabled users to optionally pull images using the unique digest assigned to an image; this way you are
not reliant on the image tags, which are not guaranteed to always point to the same version of the image.

## Inspecting a Container

Once a container has been created, we can use Docker to obtain configuration details about it, regardless of whether
or not it is currently running with `docker inspect [container id]`.
  
The long "Id" string is the full 64-byte hash that the kernel uses internally as the container's identifier - the
container id we have been using is the first 12 characters of this hash. We can also see the precise time at which 
the container was created at "Created", the top-level command in the container at "Config": {"Cmd"}, the image upon
which the container was based at "Image", and the hostname within the container at "Config: {"Hostname"}. Most of 
these configuration details can be specified by passing environment variables as arguments when creating a container.

## Getting inside a Running Container

Earlier we explored how to get inside a container that you're running from scratch, but what if we want to start a
new interactive shell inside a container that's _already_ running; we might frequently want to do so for debugging
purposes, for instance.

Originally Docker used the __LXC__ backend by default, which meant that the best way to attach to a running 
container was using the `lxc-attach` command. However, after Docker started using __libcontainer__ as a default
backend instead, we now must use tools like the `docker exec` command and `nsenter`.

### docker exec

Docker 1.3 introduced the `docker exec` command, which allows the docker client to remotely execute a shell into
a running container. Simply grap the container's id and use the following command to request a __pseudo-tty__ 
(a terminal emulation) that can be interacted with.
```
docker exec -ti [container id] /bin/bash 
```

While you can use docker exec to execute other processes through the container, in most cases it would be more
beneficial to rewrite your Dockerfile instead, since that would ensure the container's portability, and prevent
engineers deploying your code in the future from needing to input any further commands once the container is up
and running.

### nsenter

`docker exec` will in most cases be everything you need; however, there is another command you ought to know about.
`nsenter`, short for 'namespace enter', allows you to run a program with the namespaces of other processes; 
namespaces will be explored in more detail in Chapter 10, but for now it is enough to know that they are what makes
a linux container a container. In the event that a container is not responding, we can run `nsenter` from the server
to gain access to the process; we can also use it to manipulate the contents of a container as the __root__ user 
even if the container has been configured not to allow this.
 
The `nsenter` command is packaged as part of `linux-utils`, which is shipped with most Linux distributions, but
less recent distributions may not have the command already installed. In this case, the best way to install it is
through a __third-party Docker container,__ which pulls a Docker image from the registry, then runs a container
which has been crafted to install the `nsenter` tool into the /usr/local/bin folder. Use to following command to do
this.
``` 
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
```
While this is a handy way to install things on your server's system, it pays to be careful about which third-party
containers you give access to your system, since by linking the server's /usr/local/bin directory to the container 
as a volume, the container is then able to install an executable within the directory, which can have potentially
disastrous consequences if the container was created by someone untrustworthy. Chapter 10 will discuss some 
security framework options to prevent situations like this.

Since this command needs to be executed on the server system, if you are using a remote server you'll need to SSH
into it in order to install the `nsenter` tool.

## Exploring the Shell

Once we've got an interactive shell running inside a container, we can start to look around. `ps -ef` reveals that
no processes other than the initial /bin/bash command and the `ps -ef` command itself are currently running, which
is to be expected since we never told the container to do anything other than those two things! Contrast this with
a virtual machine, which would start with a host of background systems. Since containers are so much lighter than
VMs, they don't even run an __init__ system unless we ask them to - we'll revisit this concept in later chapters.

Depending on the image you used to create your container, you might have very few commands available to you - you
can install any packages you need using the `apt-get` or `yum get` command depending on the container's Linux
distribution. Keep in mind however, that anything you do install won't outlive this specific container, since any
future containers will be built from the original image.

## Returning a Result

Since containers are so much more lightweight and involve so much less overhead to create and destroy, we can use
them for all sorts of tasks for which VMs are far too cumbersome and costly. For instance, we might start a container
simply to execute a single command and return the exit code.
 
Circumstances in which this might be useful include quick remote system health checks or have a series of machines
that you want to execute quick processes on and return output. The Docker command-line tool __proxies__ the
results to the local machine, so unless we specify otherwise docker will redirect the remote process's __stdout__
and __stderr__ to your terminal.

We can test this out using `docker run ubuntu:latest /bin/false`, then `echo $?` to print out the last returned
error code, which will be the '1' returned by our container. Similarly, running the same command with `/bin/true`
will return an error code of '0'.

We might also run `/bin/cat /etc/passwd` inside the container to see the contents of the container's /etc/passwd
file, which will be returned as a regular __stdout__ output. If you wish to pass a piped command that makes use
of this output to the container's bash shell, you can't just add a | to the end of the command above, since that
will be executed on your local shell; instead, you can pass a quoted command to `docker run`, such as `/bin/bash
-c "/bin/cat /etc/passwd | wc -l"`.

## Docker Logs

Typically, logging on a Linux system would involve output going to a local logfile that you can then read, or
that output simply going being logged to the __kernel buffer__ where it can be read from __dmesg.__ The
restrictions placed upon containers mean that neither of these techniques will work out of the box, but handily
Docker provides a simple mechanism for obtaining logs through `docker logs`.

This command works by capturing anything sent to the container's __stdout__ and __stderr__ and streaming it into
a __configurable backend,__ which by default is a JSON file for each container. We can retrieve logging information
for any container at any time using `docker logs [container id]`, which is very useful for __low volume logging.__

The files containing the logged information are stored on the Docker server itself and contain a JSON object for
each log which stores information about the time and origin stream (i.e. stdout or stderr) of the log in addition 
to the log content itself. The formatting and extra information make it easier to do things with these logs later on.

You may also see a live stream of the container's logs using the `-f` flag to follow the stream from your terminal.

Log rotation is an automated process in which dated logs are archived in order to limit the size of the 
logfiles and to ensure that current logs can be easily followed. Unfortunately, Docker doesn't perform log rotation
for you, so you should investigate up-to-date techniques for implementing this yourself.

For low-volume logging this approach works well, but in the high-volume logging scenario you'll likely run into in
production-grade containers you'll need to solve the problems of log rotation, remote access to archived logs, and
disk-space usage for storing all these logs. At the time this book was published, the best option was to configure
a logging backend; syslog was the recommended option and can be specified by adding the `--log-driver=syslog`
argument to the container's `create` or `run` command. Keep in mind that redirecting the logs to anything other than
the default json-file will mean that the `docker logs` command will no longer work, so you'll need to find or create
another tool for accessing your logs. Be sure to investigate this further since at the books's release date even this
approach was not robust enough to be used in production.

Other alternatives to this method include: logging directly from your application; having a __process manager__ in
our container relay the logs (e.g. systemd, upstart, supervisor, runit); running a __logging relay__ in the
container which wraps stdout/stderr; relaying the Docker JSON logs themselves to syslog from the server.

Finally, while in almost all cases you should be keeping logs, you may disable them for a container using the 
`--log-driver=none` argument.

## Monitoring Docker

When running a production-grade application we need to be able to monitor everything about it closely; Docker
provides some nice tools to help us achieve maximum coverage of all our app's goings on.

### Container Stats

Docker version 1.5.0 introduced an endpoint enabling the viewing of a running container's stats; using the `docker
stats [container id]` command will take over our terminal and stream these stats from the endpoint, updating them
every few seconds so we get a real time view of what is happening inside the container. If we run the command we'll
see the container's id, name, CPU usage, memory usage and limit, the percentage of the memory limit it's 
currently using, and a few other things.

The information provided by the command-line tool can be useful, but is very limited compared to the stats the Docker
API is capable of showing us, so let's look at how to call the API ourselves. We'll be requesting data from the API's
/stats/ endpoint, which will bombard us with hard-to-read information as long as the connection remains open, so
we'll use a tool to pretty print it.

Firstly we'll start a container whose stats we'll monitor.
```
docker run -d ubuntu:latest sleep 1000 
```
Then we can run a `curl` command with the container's hash.
```
curl -unix-sock /var/run/docker.sock http://localhost/containers/<container-hash-or-name>/stats
```
And to pretty print it we can pipe the output to a tool such as `jq`, which will make the whole thing human-readable!
There is a lot of information here, but __blkio__ and __CPU usage__ information are particularly helpful if you 
are using CPU or memory limits in your container.

There we have it! You can use this API endpoint if you're doing your own monitoring, although this approach is
slightly limited in that you can only access endpoints on a container-by-container basis, not all in a single call.

## Docker Events

The docker daemon keeps track of key aspects of the containers' life cycles by generating an __events stream__ -
it also uses this to keep various parts of the system aware of each other's status. We can hook into this event
stream using the command-line tool's `docker events` command, which will __block__ the terminal and stream messages
to you about your containers. Under the hood, the Docker client is making a long-lived request to the Docker API, 
which is returning event messages in __JSON blobs__ as and when they are generated, and the docker CLI tool is 
then decoding them and printing some of the data to the terminal.

This stream can be useful for both monitoring and for triggering actions in response to key events such as a
container restart. At some point it will become worth looking into hooking into this API call with your own tooling.
 
When we instruct a container to `stop`, this generates a 'container die' message in the event stream, after which
it will log certain key shutdown events such as 'network disconnect' and 'volume mount' before finally registering
the 'container stop' event. The container's ID is also included in each event message, along with the name of the
image on which it was built.

When instructing a container to `start`, we get a 'start' event message if the container successfully started, but
if it failed we simply get a 'die' message.

In addition to a live event stream, Docker will also cache some events so that you can access them for a certain
period after they happened. You can access these using the `--since` and `--before` options, or use both 
simultaneously to limit the scope of your query to a narrow window of time. These arguments accept ISO time formats.

## cAdvisor

While these tools are undoubtedly useful when monitoring live containers, it would be nice to have a graphic 
representation of our container activity; there are many commercial and open source tools that aim to provide this
functionality.

