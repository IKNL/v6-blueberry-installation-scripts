# vantage6 BLUEBERRY Installation Scripts

This repository contains convenience scripts for installing vantage6 nodes at data stations participating in the BLUEBERRY project.

## Getting Started
These instructions will get you a running vantage6 node that is connected to the
BLUEBERRY server.

### Prerequisites

- The scripts are designed to run on an Oracle Linux 8 Machine (server edition).
- During installation it requires internet access to download the necessary packages.
- `sudo` permissions
- Install git:
    ```
    sudo dnf update -y
    sudo dnf install git -y
    ```



### Installing

To get started with these scripts, follow these steps:

1. Clone this repository to your local machine: `git clone https://github.com/IKNL/v6-blueberry-installation-scripts.git`
3. Navigate to the cloned repository: `cd v6-blueberry-installation-scripts`
4. Add execute permissions to the scripts: `chmod +x *.sh`
5. Run the `install-all.sh` script: `./install-all.sh`. This will install all the necessary components and configure them for you.

### Lifecycle management

The `./install-all.sh` script is designed to run multiple times. You can also use it
to update the vantage6 node to the latest version. It will not overwrite any configuration files except if you explicitly tell it to do so.

You have the following scripts available to manage the vantage6 node:

- `./start.sh` - Starts the vantage6 node
- `./stop.sh` - Stops the vantage6 node
- `./attach.sh` - View the logs of the vantage6 node if its running


## License

This project is licensed under the License - see the [LICENSE](LICENSE) file for details