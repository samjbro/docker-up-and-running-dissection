# Chapter 7 - The Path to Production Containers

Taking a container into production is a complex process requiring configuration specific to your particular 
requirements; this chapter does not intend to be an exhaustive guide, and will instead focus on providing you with
information sufficient to give you a starting point for you to design your own configuration.

## Deploying

Deployment has traditionally been one of the most finicky parts of bringing an application into production; Docker
has simplified and standardised the whole process to make it much more friendly.

Before shipping containers existed, produce was loaded onto ships in individual boxes of greatly irregular sizes and
shapes, carefully stacked in a way that they would hopefully survive the journey, and then tentatively unloaded at 
their destination by someone who more or less had to have the eye of a structural engineer to ensure the whole mess 
didn't come crashing down mid-unload. The invention and mass adoption of shipping containers removed all of this 
irregularity and unpredictability, since any package could now be treated in the same way as any other, regardless 
of the contents of the container. What shipping containers did for the shipping industry, Docker has done for the 
deployment process; all Docker containers have the same __external interface__ and the available tools enable you to 
drop them onto the servers without worrying about their contents.

The path to deployment will take you through the following stages:
1) Locally build and test a Docker image on your development box.
2) Build your official image for testing and deployment.
3) Deploy your Docker image to the server.
Once your workflow is functioning smoothly, you will be able to treat all these stages as a single step:
1) Orchestrate the deployment of images and creation of containers on production servers.

### Classes of Tooling

While the simplest way to take an app into production is to deploy it on the server manually using the `docker run`
command, this is not a reliable enough solution for anything other than testing and development. Even the most basic
__deployment story__ must tick the following two boxes:
1) It must be __repeatable;__ every time you invoke it it must behave in exactly the same way.
2) It must take care of your __container configuration__ for you; once you've initially defined your configuration
it must ensure that that configuration is applied to each and every container deployed.

The first problem that needs to be solved when deploying an application at any sort of scale is that the Docker client
is limited to communicating with only one server, which means that you'll need an __orchestration tool__ such as
__Docker Swarm__ in order to talk to multiple servers. In addition to that, you still need to tick the two boxes
mentioned above. One way of doing so is to script the behaviour you require using __shell scripting__ or by using a
__dynamic language;__ you could use these to communicate directly with the Docker Remote API, thus exposing the
functionality of the command-line tool in a __programmatically accessible__ way.
  
If you don't want to build your own tools, which should include most people, there are many robust, 
community-contributed solutions that will be much more powerful than anything you create yourself; these solutions
tend to fall into one of two groups depending upon how they approach the problem:
1) Tools that look at this as an __orchestration__ or __deployment__ problem, which take the place of other tools like
Capistrano, Fabric and shell scripts.
2) Tools that look at your network as one large computer and implement __automatic scheduling__ and/or __fleet
management policies,__ usually replacing manual processes altogether.

### Orchestration Tools

This class of tooling enables you to coordinate the configuration and deployment of your Docker containers onto
multiple servers more or less simultaneously; you give the tool a set of instructions and then wait while it
executes them while you wait. Options include New Relic's __Centurion,__ Spotify's __Helios__ and __Ansible__'s
Docker tooling.

These tools tend to be the simplest way of getting a Docker application into production, since they require the least
__infrastructure__ or modification to your existing system, they don't take long to set up, and they are
designed to work well with Docker's interface. Important processes like __zero-down-time deployment__ are available
out of the box.

Centurion and Helios are purely orchestration tools, while Ansible is also a __system-configuration management__
platform which can also configure and manage your servers. While the only external resource required by Centurion 
and Ansible is a Docker registry, Helios additionally requires an __Apache Zookeeper__ cluster.

### Distributed Schedulers

Another approach is to make use of a __distributed scheduler__ to treat your entire network as a single computer;
you can then design __policies__ about how you want your application to run, and let the system figure out things
like where to run it and how many instances should be run. In this approach the scheduler is made responsible for
responding to anything that goes wrong, letting it restart failed processes on resources that are healthy. This
approach is much more in keeping with the original design principle for Docker, since it allows your application
to run regardless of where it is or how it got there. This approach tends to solve the zero-downtime deployment
in the [blue-green](https://martinfowler.com/bliki/BlueGreenDeployment.html) style, which involves launching
multiple generations of an application simultaneously and slowly filtering new work from the old generation to the
new.

One of the most popular tools in this area is Google's __Kubernetes.__ While it makes few assumptions about your OS
distribution, allowing it to be run on more OS and provider options than many other similar tools, it requires that
your hosts be set up in a specific way. It also has an entire __network layer__ of its own, for which you must run
an IP-over_UDP layer called Flannel, which sits on top of your real network. Kubernetes requires __etcd__ and supports
a number of backends besides the Docker daemon, including Google Compute Engine, Rackspace and Azure.

The most mature option available is __Apache Mesos,__ which has been implemented by Twitter and Airbnb and is held
up by Docker's original designer as being the gold standard of clustered container management. It is a __framework
abstraction__ that allows you to run multiple frameworks on the same cluster of hosts; for instance, you can run
Docker applications as well as Hadoop jobs on the same cluster. Mesos uses Zookeeper as its key-value store. While
it actually predates Docker, it has recently added excellent support for Docker; alternatively there are popular
Mesos frameworks such as Mesosphere's __Marathon__ and Apache's __Aurora__ which also support Docker. Mesos is 
probably the most powerful Docker platform, but requires more decisions to be made in order to get it up and 
running. Mesos is a complicated system and lies outside the scope of this book, though when you are ready to learn
more about serious at-scale deployment you should learn more.

Docker has also released its own clustering tool called __Swarm,__ which presents a large number of Docker hosts
as a single __resource pool.__ Swarm is designed to be lightweight, and has a narrower focus than Kubernetes or
Mesos, but is fairly powerful and can work on top of other tools if necessary. A single Docker Swarm container has
the capacity to create and coordinate container deployment across a large Docker cluster.
 
### Deployment Wrap-Up

When starting out with Docker you can get by with simple orchestration tools, but as the number of containers grows
and the frequency with which you require containers to be deployed increases, you'll begin to see the true benefit
of using a distributed scheduler to coordinate this work for you. Mesos and similar tools enable you to abstract
individual servers an whole data centres into large pools of resources in which to run container-based tasks.

A good rule of thumb is to always use the lightest weight tooling for the job, which when you start out will be
Docker's built-in tooling and maybe some additional bash scripting. Start off by getting your Docker infrastructure
up and running, and then look for additional external tooling as and when it becomes required.

## Testing Containers

A major benefit to using Docker is the ability to test your application under identical conditions to those it will
experience in production, including all the same dependencies; this makes your tests much more reliable, since 
inconsistencies in underlying dependencies are key areas in which a project can go wrong. Docker enables you to 
build your image, run it on your development system, test it with identical dependencies and then ship it to a
production server, secure in the knowledge that no little environmental quirks or dependency issues can arise at any 
point in your workflow.

In order to test a Dockerised application you'll need to do a few things differently than when testing a regular
app, including setting up a Docker server for your test environment and using environment variables or command-line
arguments to tell your app to modify certain behaviour for testing purposes.

### Quick Overview

To illustrate how to test a Dockerised app let's say we have a __pool__ of __production servers__ that run __Docker
daemons,__ and an assortment of __applications__ deployed there. We also have a __build server__ and some __test
worker boxes__ that are tied to a __test server.__ We'll ignore deployment until we have something that's tested
and ready to ship.

A common workflow for testing a Dockerised application can be broken down into the following stages:
1) A build is triggered by some outside means, e.g. a job or command-line input.
2) The build server kicks off a Docker build.
3) The image is created on the local `docker`.
4) The image is tagged with a build number or commit hash.
5) A container is configured to run the test suite based on the newly built image.
6) The test suite is run against the container and the result is captured by the build server.
7) The build is marked as passing or failing.
8) Passed builds are shipped to an image store (registry, etc.)

This workflow works in our fictional setup as follows; first, we push our code's latest changes to a repository,
on which we have a post-commit hook that triggers an image build on the build server whenever a commit takes place.
We have a job set up on the test server that talks to a `docker` instance on a test worker server; the test server
itself does not have `docker` installed, but does have the Docker CLI tool, so we can run `docker build` from the
test server against the remote test worker server to generate a new image on the worker server (if our environment
is small enough we can avoid using worker servers and just run `docker` on the test server itself).
 
Something to consider throughout this process is that our container image needs to be exactly the same for 
testing as it is in production, so any tweaks we'll need to make for our test container will need to be externally 
provided __switches,__ either through __environment variables__ or __command-line arguments.__

With that in mind, now that the image is built our test job will run a container based on that image; however the
image should by default be configured to run the application in a production environment, so we need to flip whatever
switches we have in place in order to run a version of the app that is configured for testing. In our example
application's production environment we'd use __supervisor__ to start up an __nginx__ instance and some Ruby 
__unicorn__ web server instances, but we don't need any of this for our tests. The command we can use to flip the
switch that prevents these processes from running is:
```
docker run -e ENVIRONMENT=testing -e API_KEY=12345 \
-it awesome_app:version1 /opt/awesome_app/test.sh
```

When we called `docker run`, we also passed ENVIRONMENT and API_KEY variables, which we can use throughout our app
to run our application in test mode. We also specified the specific version of our image that we want to run our
tests against, since if we used 'latest' we would have no guarantee that our tests would not be running against an 
unexpected subsequent build of the app. Finally we override whatever default CMD the app would ordinarily execute
once it was built and tell it to execute our `/opt/awesome_app/test.sh` bash file instead, which will run our tests.

One important point to note is that `docker run` will not output the result of our tests, so we will have no way of 
knowing if our build passed or failed. A good way to capture this feedback is to write the results of our test to a
file with a 'Result: SUCCESS!' or a 'Result: FAILURE!' message at the end as appropriate, then telling our test.sh
command to echo out this result message so that we can see it.

Finally, once we've received confirmation that our build passes our tests, we want to `tag` our build with a new
version number and the 'latest' tag, and `push` it to our image registry.

If you follow this workflow, you'll have ensured that you only ship applications to production that have passed their
entire test suite on exactly the same Linux distribution, with identical dependencies and build settings as those
in the production environment.

If you intend to use __Jenkins__ for __continuous integration__ it offers many useful plugins that can help with this
process.

### Outside Dependencies

Our example above does not cover what to do when you are confronted with the common situation of needing external
dependencies such as a database or another service in order for your application to run. In those cases, you can
use tools like __Docker Compose__ to network several containers together. Since Docker's __link__ mechanism only
works on a single host (NOTE: does this for networks too?), Compose is only suitable for testing and development.