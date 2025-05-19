# FRI Minix Docker Environment

This documentation file provides instructions for setting up and using the **FRI Minix Docker environment**.

This project is a part of the Bachelor Thesis titled **Instructional Operating Systems** by Dejan Jarc from the Faculty of Computer Science and Informatics (University of Ljubljana, Slovenia). It is meant to serve as a pedagogical tool for OS courses, but can also be used by any OS enthusiast.

> The base system we are using in this project is **Debian 10.9**.

## Prerequisites

Before proceeding, ensure you have the following prerequisites set up:

1. **Install Docker and Docker Compose**:
    Make sure Docker and Docker Compose are installed on your system. You can download and install them from the [Docker website](https://www.docker.com/). **The best way is to setup [Docker Desktop](https://www.docker.com/products/docker-desktop/).**
    

    > For Windows users, it is recommended to enable *Windows Subsystem for Linux (WSL)* within Docker Desktop for better compatibility.

2. **Verify Docker Installation**:
    Confirm that Docker is installed and running by executing:
    ```bash
    docker --version
    docker-compose --version
    ```
---
## Getting Started

You can setup the Docker environment using Docker Hub.

1. **Pull the image from Docker Hub**

    ```bash
    docker pull dejanjarc/fri-minix
    ```
    or (when in the directory of the Docker Compose file):
    ```bash
    docker compose pull
    ```
2. **Run a named container**
    ```bash
     docker run --name <CONTAINER_NAME> -itd dejanjarc/fri-minix 
    ```
Replace `<CONTAINER_NAME>` with the name of your Minix container. You can choose your own name.
The flag `-d` is there so that we run the container detached. 

3. **Connect to the Running Container**:
    Once the containers are running, you can connect to the Minix container by executing:
    ```bash
    docker exec -it <CONTAINER_NAME> /bin/bash
    ```
    Replace `<CONTAINER_NAME>` with the name or ID of the Minix container. To find the container name or ID, run:
    ```bash
    docker ps
    ```

    Alternatively, you can attach to the container using:
    ```bash
    docker attach <CONTAINER_NAME>
    ```
    You need to run this commant to start the container again if you detach:
    ```bash
    docker start <CONTAINER_NAME>
    ``` 
    > It is recommended to use the `docker exec` instead so that your container doesn't always stop after you detach from it.

You are now ready to use the FRI Minix Docker environment.

#### **Alternative for getting started** 
1. **Clone the Repository**:
    Begin by cloning the repository from GitHub to your local machine:
    
    ```bash
    git clone https://github.com/dejanjarc/fri-minix.git
    cd fri-minix
    ```

2. **Build and Start the Docker Environment**:
    Build and start the Docker containers using the following command:
    ```bash
    docker-compose up --build
    ```
    or
    ```bash
    docker-compose build
    docker-compose up -d    
    ```

3. **Connect to the Running Container**:
    Once the containers are running, you can connect to the Minix container by executing:
    ```bash
    docker exec -it <CONTAINER_NAME> /bin/bash
    ```
    Replace `<CONTAINER_NAME>` with the name or ID of the Minix container. Default value for `CONTAINER_NAME` is `fri-minix` To find the container name or ID, run:
    ```bash
    docker ps
    ```

    Alternatively, you can attach to the container using:
    ```bash
    docker attach <container_name>
    ```
    You need to run this commant to start the container again if you detach:
    ```bash
    docker start <CONTAINER_NAME>
    ``` 
    > It is recommended to use the `docker exec` instead so that your container doesn't always stop after you detach from it.
---
## Container overview

The container home directory contains:
- a **Minix source code directory** (`minix-master`) which includes tools for compiling from source code
- a **Minix ISO image** (`minix_v$VERSION.iso`)
- scripts **`run.sh`** and **`setup.sh`** for streamlining the running and setup process for Minix


---
## Setting up Minix

That can be done in two ways:
1. [using the provided ISO image](#iso-image)

2. [cross-compiling from source code](#cross-compiling-from-source-code)

The credentials for the system withing the container are: 
Username = **minix**, password = **minix** 
> If needed, you can freely install any packages you may require. If admin rights are needed, use the mentioned credentials.

1. #### **ISO image**

    1) You can execute **`setup.sh`** for creating an `.img` file, which can then be used to boot with the `.iso` file provided. After an `.img` file exists (including the one you create [here](#cross-compiling-from-source-code)), you can use **`run.sh`** to boot Minix from that image file.
        > You can also manually follow this [QEMU/KVM guide](https://wiki.minix3.org/doku.php?id=usersguide:runningonqemu) which were the basis for the scripts.
    
        Example:
        ```bash
        bash setup.sh
        ```
        > By default, creates a `minix.img` image file (2GB) and boots the ISO file to it (auto-detects `.iso` files in home directory). 

        and 
        ```bash
        bash run.sh
        ```

    2) From there you must follow this [Installation guide](https://wiki.minix3.org/doku.php?id=usersguide:doinginstallation#installing) to install Minix. The process is very straightforward so just closely follow the steps. 

    3) After that follow this [Post-Installation guide](https://wiki.minix3.org/doku.php?id=usersguide:postinstallation) to finalize your Minix installation.

    > **IMPORTANT :** To exit Minix after you ran QEMU (with `run.sh`, `setup.sh` or manually) you can hit **`ALT+2`** to switch to the QEMU monitor console and input **`quit`** to stop QEMU.  

2. #### **Cross-compiling from source code**

    In this step it is expected you build your own Minix image. There are scripts present in the `minix-master` source directory.

    > You can follow this [Cross-compilation guide](https://wiki.minix3.org/doku.php?id=developersguide:crosscompiling) in case you have any trouble using the steps below or if you want to cross-compile differently.


    1) First, move to the source code directory:
    ```bash
    cd minix-master
    ```
    2) You can run the following command here:
    ```bash
    bash ./releasetools/x86_hdimage.sh
    ```
    > This script generates object files outside of the source directory. It will also take a lot of time to finish the first time it is executed and will create a lot of output. *Be patient.*

    3) After this process finishes, you will be able to find a new `.img` image file in the directory `minix-master`. This is the image file you can now use to run the script `run.sh`.
    ```bash
    bash run.sh -n <MINIX_IMG.img>
    ```
---
## Using Minix

Once you have Minix ready to use you can start using and developing it! You can look into [the documentation](https://wiki.minix3.org/doku.php?id=www:documentation:start). There are a lot of useful guides that will help you through the Minix journey.

For development you should read [the development guide](https://wiki.minix3.org/doku.php?id=developersguide:start). There are also many forums and dev groups. There is also the [Github repository](https://github.com/Stichting-MINIX-Research-Foundation/minix) where you could get help by opening an issue or look through already solved issues and pull requests.

The main documentation is the book titled **Operating Systems: Design and Implementation 3/e by Andrew S. Tanenbaum and Albert S. Woodhull**. It is generally available on the Internet or can be purchased as a physical copy. 

---
## References
- [Minix 3 Wiki](https://wiki.minix3.org/)
- [Minix Github repository](https://github.com/Stichting-MINIX-Research-Foundation/minix)
- *Operating Systems: Design and Implementation 3/e* by Andrew S. Tanenbaum and Albert S. Woodhull. Prentice Hall, 2006.
---
## Notes

- Ensure Docker and Docker Compose are installed on your system before proceeding.
- Use the scripts in the home directory to streamline repetitive tasks. Use flag `-h` or `--help` when running the scripts to get more information.
- If there are any bugs you wish to report, [open an issue or do a pull request with your solution](https://github.com/dejanjarc/fri-minix).
