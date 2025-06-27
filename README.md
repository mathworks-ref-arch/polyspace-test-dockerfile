# Build and Customize a Polyspace Test Docker Image

This repository shows you how to build and customize a Docker image for Polyspace Test&trade;, using the [MATLAB&reg; Package Manager (*mpm*)](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md).

You can use this image as a scalable and reproducible method to run Polyspace Test command-line interfaces in containers.

## Requirements

* A valid Polyspace Test license
* The port and host name of a [Network License Manager](https://www.mathworks.com/help/install/administer-network-licenses.html) or the path of a `network.lic` license file. See [Use Network License Manager](#use-network-license-manager).
* Linux® Operating System
* [Docker](https://docs.docker.com/engine/install/)
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Get Started

### Get Sources and Build Docker Image

 Use these commands to clone this repository and build the Docker image:

>**Note:** If you use the `demo` files in the [Run Docker Container](#run-docker-container) example, uncomment one of these lines <br> `# RUN apt-get install --no-install-recommends --yes gcc g++` (Ubuntu)<br>`# RUN yum install --disableplugin=subscription-manager -y gcc gcc-c++` (UBI)<br>in the `Dockerfile`, or check that you add the correct dependencies if you use a different compiler.

```bash
# Clone this repository to your machine.
git clone https://github.com/mathworks-ref-arch/polyspace-test-dockerfile.git

# Navigate to the downloaded folder.
cd polyspace-test-dockerfile

# Select a base image for the container you want to build, for example, Ubuntu, and copy it to a Dockerfile.
cp Dockerfile.ubuntu24.04 Dockerfile

# Build container with a name and tag of your choice.
docker build . -t polyspace-test:r2025a
```

The `build` command looks for the `Dockerfile` in the current directory and builds an image with the name and tag specified by the `-t` option.

If you list the docker images and filter for `polyspace*` after the `docker build` command completes, you see the polyspace-test image.

```bash
$ docker images -f=reference=polyspace*
REPOSITORY       TAG       IMAGE ID       CREATED              SIZE
polyspace-test   r2025a    d11ca6c44b9c   About a minute ago   5.53GB
```

### Run Docker Container

After you build the image, you can start using Polyspace Test by creating and running containers from the image you built in the previous section. To create and run a container, see the [`docker run`](https://docs.docker.com/engine/reference/commandline/run/) command.

For example, you can test your installation by running the script in the `demo` folder. The folder contains:

* A source file `file.c` which defines a function to test.
* A test file `test.c` which contains a test written using the [Polyspace Test xUnit API](https://www.mathworks.com/help/polyspace_test/gs/write-simple-c-or-c-unit-test-using-polyspace-test-api.html).
* A script file `demo_script.sh` which performs these steps:
  1. Test registration, which generates a file that contains a registration function for the test and a `main()` function to call the test.
  1. Test building and running, which builds the test, generates a test runner, runs the test, and outputs the results in the terminal.

To run the `demo` example, enter these commands:

```bash
# Change permissions for demo folder
chmod 777 demo
cd demo
# Build container and run demo script
docker run --rm -v "$(pwd):/work" \
-e MLM_LICENSE_FILE=27000@MyServerName.example.com \
polyspace-test:r2025a /work/demo_script.sh
```

After running the test, you see an output similar to this in the terminal:

```bash
| Running tests   |            |                      | 2023-10-06 17:01:08
|-----------------|------------|
| Running         | suite      | pst_default_suite
|-----------------|------------|
| Running         | test       | test_sum_correct
|            PASS | test       | test_sum_correct     | time: 0.000s
|-----------------|------------|
|            PASS | suite      | pst_default_suite    | time: 0.000s
|-----------------|------------|
|            DONE |            |                      | time: 0.000s

|        |  Total | Passed | Failed | Incomplete
|--------|--------|--------|--------|------------
| Suites |      1 |      1 |      0 |          0
|  Tests |      1 |      1 |      0 |          0
```

Docker automatically cleans up each container and removes its file system when that container exits (`--rm` option).

## Customize Docker Image

The [Dockerfile](https://github.com/mathworks-ref-arch/polyspace-test-dockerfile/blob/main/Dockerfile) supports these Docker build-time variables.

| Argument Name | Default value | Description |
|---|---|---|
| MATLAB_RELEASE | r2025a | The Polyspace Test release you want to install. Must be lower-case, for example: `r2024b`.|
| [LICENSE_SERVER](#specify-license-server-information-in-build-image) | *unset* | The port and hostname of the machine that is running the Network License Manager, using the `port@hostname` syntax. For example: `27000@MyServerName`. |

To customize the docker image, use these arguments with the `docker build` command or edit the default values of these arguments directly in the [Dockerfile](https://github.com/mathworks-ref-arch/polyspace-test-dockerfile/blob/main/Dockerfile).

### Examples

#### **Specify License Server Information in Build Image**

If you include the [license manager information](#obtain-license-manager-information) when you run the `docker build` command, you do not have to specify the `MLM_LICENSE_FILE` variable when you run the container using the `docker run` command.

```bash
# Build container and specify LICENSE_SERVER variable
docker build -t polyspace-test:r2025a --build-arg LICENSE_SERVER=27000@MyServerName.example.com .

# Run the container without specifying the MLM_LICENSE_FILE variable
docker run --rm -v "$(pwd):/work" \
polyspace-test:r2025a /work/demo_script.sh
```

> **Note**: If you specify the value of the LICENSE_SERVER variable in the Dockerfile, you can omit it when running the `docker build` command.
>
## Use Network License Manager

The Polyspace Test product uses a concurrent license which requires a Network License Manager to manage license checkouts.

To enable the container to communicate with the license manager, you must provide the port and hostname of the machine where you installed the license manager or the path to the  `network.lic` file.

### Obtain License Manager Information

Contact your license administrator to obtain the address of your license server, for instance:

 `27000@MyServerName.example.com`, or the path to the `network.lic` file.

You can also get the license manager port and hostname from the `SERVER` line of the `network.lic` file or the `license.dat` file.

```bash
# Sample network.lic
SERVER MyServerName.example.com <optional-mac-address> 27000
USE_SERVER

# Snippet from sample license.dat
SERVER MyServerName.example.com <mac-address> 27000
...
```

### Pass License Manager Information to `build` or `run` Commands

To pass the license manager address (`portNumber@hostname`) to the:

* `docker build` command, assign the address to the [LICENSE_SERVER](#specify-license-server-information-in-build-image) build variable.
* `docker run` command, assign the address to the [MLM_LICENSE_FILE](#run-docker-image) environment variable.

To use the `network.lic` file instead:

1. Copy the file to the same folder as the `Dockerfile`.
1. Uncomment the line `COPY network.lic /opt/matlab/licenses/` in the Dockerfile.

    You do not need to specify the `LICENSE_SERVER` build variable when running the `docker build` command:

    ```bash
    # Example
    docker build -t polyspace-test:r2025a .
    ```

## Remove Docker Image

While docker cleans up containers on exit, the docker image persists in your file system until you explicitly delete it. To delete a docker image, run the `docker image rm` command and specify the name of the container. For instance:

```bash
docker image rm polyspace-test:r2025a
```

---

## More MathWorks Docker Resources

* Explore prebuilt MATLAB Docker Containers on [Docker Hub](https://hub.docker.com/r/mathworks):
  * [MATLAB Containers on Docker Hub](https://hub.docker.com/r/mathworks/matlab) hosts container images for multiple MATLAB releases.
  * [MATLAB Deep Learning Container Docker Hub repository](https://hub.docker.com/r/mathworks/matlab-deep-learning) hosts container images with toolboxes suitable for deep learning.

## Feedback

If you encounter a technical issue or have an enhancement request after trying this repository with your environment, create an issue [here](https://github.com/mathworks-ref-arch/polyspace-test-dockerfile/issues).

---

Copyright (c) 2023-2025 The MathWorks, Inc. All rights reserved.

---
