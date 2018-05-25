# Personal Notes

- Where is the Docker server located when using Docker for Mac? I think maybe things have changed since this
  book was written, since the Docker for Mac documentation talks about the Docker daemon and the Docker engine,
  but not the Docker server. 
   
- Apparently Docker for Mac uses a Linux Virtual Machine created by Hyperkit for storing and running containers
  on a Mac.
nt logs can be easily followed.

- Testing a build is very different to testing during development; we don't care a jot about individual tests, and 
 only want to check that every test is passing. Since the testing environment will be identical to our development
 environment, other than a few testing switches being thrown, the results of the tests should also be identical;
 we are therefore only using the automated post-commit tests as a safeguard against test-breaking commits.
 
 - If our application is going to be split into multiple repositories, we need to have a well-defined mechanism for
 determining which versions of each service were used in a build.
 
 - What happens in cases where a necessary change to multiple services within our application ecosystem would break 
 the e2e/integration tests? If both changes are required in order for the tests to pass, we need a way to get past the
  barrier of updating the first one. This book mentions an __integration environment;__ perhaps each individual repo
  could have its own tests, and then have integration tests that run on a group of services and need to be passed
  before the application as a whole can be deployed to production?
  
 - Developers can build their application, test it, ship the final image to the registry, and deploy the image to the 
 production environment, while the operations team can focus on build‐ ing excellent deployment and cluster management 
 tooling that pulls from the registry, runs reliably, and ensures environmental health. Operations teams can provide 
 feedback to developers and see it tested at build time rather than waiting to find problems when the application is 
 shipped to production. This enables both teams to focus on what they do best without a multi-phased hand-off process.