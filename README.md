# GTM Worker
[![Docker Build Status](https://img.shields.io/docker/build/zotoio/gtm-worker.svg?a=a)](https://hub.docker.com/r/zotoio/gtm-worker)

A general purpose docker image for execution by [Github Task Manager](https://github.com/zotoio/github-task-manager) agents using the Docker Executor.  Tools such as nodejs, maven, java, gradle and sonar-scanner are baked in.

## Why?
To execute standalone adhoc builds and test runs, driven by environment variables passed in from GTM Agents servicing pull request hooks, without the overhead of managing external CI jobs.

## How?
The Github Task Manager Docker executor can pull a docker image, and run it with a set of environment vars and an adhoc command.  This docker image incorporates a number of common tools that are useful for build and test executions.

## Install
The image is intended to be used by Github Task Manager, meaning no direct install is required.

Follow the guide [here](https://github.com/zotoio/github-task-manager/wiki/Structure-of-.githubTaskManager.json#docker-options) for implementation steps using the `zotoio/gtm-worker` docker image.

To run it locally for experimentation, create a `.env` file base on `.envSample` and:

```
docker run -it --env-file .env --net=host  zotoio/gtm-worker /bin/bash
```
..then use the scripts in the /usr/workspace directory.

For sonarqube support, install and configure the official docker image:
```
docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 sonarqube
```

## Configuration

| Environment variable | description |
| -------------------- | ----------- |
|SONAR_HOST_URL| eg. http://localhost:9000 |
|SONAR_LOGIN|access token from SonarQube|
|SONAR_PROJECTNAME_PREFIX| prefix to append for display in sonarqube - not used for pull requests |
|SONAR_SOURCES| default is 'src' which is in the default checkout location|
|SONAR_JAVA_BINARIES| default is 'target' which is in the default checkout location|
|SONAR_MODULES| optional comma separated list of modules. sonar will look for source and target within each|
|SONAR_GITHUB_REPOSITORY| git org/repo eg. zotoio/gtm-agent|
|SONAR_ANALYSIS_MODE| 'preview' used for pull requests |
|SONAR_GITHUB_OAUTH| github personal access token|
|SONAR_KEEP_PROJECT_PROPERTIES| If not `true`, delete any `sonar-project.properties` files in repo|
|GIT_CLONE| git clone uri eg, https://github.com/org/repo.git|
|GIT_PR_BRANCHNAME| branch name from PR event|
|GIT_PR_ID| pull request number from PR event|
|BUILD_TYPE|nodejs or maven or gradle|
|BUILD_COMMAND|custom build command rather than derived from build type|

