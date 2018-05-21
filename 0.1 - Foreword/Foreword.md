# Foreword

[Linux containers]() are not a new concept - they've been around for many years, but have rarely been 
used because of the complexity involved in putting the concept into practice. In the cases where 
they have been used in a practical situation, they've been implemented with a specific purpose in 
mind, making them unsuited for [scaling]() or [portability]().

This is where Docker comes in - it has removed the complexity from setting up a application based on 
Linux containers by creating a [standardised packaging format]() and devising a maintenance and 
configuration system that is easy to use. As a result, Linux containers are now accessible enough
to be used by [DevOps]() teams everywhere, and in so doing, the community is realising the benefits
of the [application portability](), [simplified integration]()and [streamlined development]() that
Linux containers offer, but which were heretofore inaccessible due to the complexity involved in
using them.

Docker has supercharged Linux containers to the point where they are transforming the IT and 
development landscape - their mass adoption has led to a great deal of experimentation and innovation
as the community explores the potential of Linux containers across a wide range of computing 
environments, platforms and skill sets.

Docker itself has only been made possible by years of progress made within the Linux sphere, and this 
origin has provided and shaped Docker's core capabilities; however, Docker has now matured to the point
that it can replicate its functionality in operating systems besides Linux.

Docker has brought about a profound [disruptive]() change in the professional technology community,
and has caused a re-evaluation of which aspects of [application development](), [application delivery]() 
and [infrastructure management]() we should consider to be core parts of professionals' repertoire, and for
which aspects we should develop tools and abstractions to assist the average developer. Even deeper than
this, though - Docker has caused the community to re-evaluate the nature of the application itself.
 
The most profound impact Docker has had on the tech community is that it has enabled us to redefine the 
traditional organisational boundaries between [business](), [application deployment]() and 
[IT infrastructure]() teams. In particular, it enables the merging of the [development]() and [operations]()
teams into one [DevOps]() team. [Containerization]() is a large step into the future for the technology
stack and processes, enabling centralised ownership and reducing the costly coordination of handovers.

Docker is both a [packaging format]() and a [unifying interface](), which allows the [application team]() 
to own the Docker-formatted container image (including all dependencies), while allowing the [operations team]()
to retain [infrastructure]() ownership. With this system in place, the organisation can hold the application
team accountable for the security and cost impact of their own code, when it is deployed inside the container.

A happy side-effect of a Docker implementation is that an application becomes much more efficient in terms of
both scale and performance, since each container only has the dependencies installed that are completely 
necessary in order to perform their function, resulting in container sizes of often only dozens to hundreds
of megabytes. Traditional [virtual machine]() images, on the other hand, consume gigabytes of storage, and
are less performant.
 
Another advantage containers have over virtual machines is in deployment speed - they take milliseconds to 
start up, as opposed to a virtual machine's minutes. This enables Docker-based apps to be more efficient and 
elastic in terms of [frequent state changes]() and [dynamic allocation of resources]().
  
The most profound and important innovation that Docker enables is that it allows the traditional 
[monolithic]() application stack to be broken down into dozens or even hundreds of tiny, independent 
applications that work in concert to perform the same function as the monolithic implementation, but which 
also allows the individual apps to be rewritten, reused and managed as independent entities, allowing 
for far greater efficiency than the monolithic app.

While containers are the future of the app development world, they do bring with them a particular set of
challenges; most importantly [management](), [security]() and [certification](). Containers must be deployed 
on a secure host, but we must also make sure that the contents of the containers are free from 
[vulnerabilities](), [malware]() and [known exploits]() - having an appropriate [signature]() on the container
from a certified source can assuage these fears. Management, on the other hand, requires a great deal of
thought, since coordinating up to hundreds of individual containers has the potential to become exponentially
more complex than managing a single monolithic application. Some questions to consider are how [updates and
rollbacks]() are handled; how [sprawl]() is defined; when to [retire]() or [archive]() a container. These 
are all problems in need of solutions before a containerised application is ready for enterprise.

These challenges are surmountable, however, and Linux Containers and Docker are fundamentally changing the
way in which applications are created, consumed and managed, since they allow for improved flexibility,
portability, and efficiency across the [datacenter and hybrid clouds]().