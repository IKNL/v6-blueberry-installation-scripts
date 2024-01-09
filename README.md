# vantage6 BLUEBERRY Installation Scripts

This repository contains convenience scripts for installing vantage6 nodes at data stations participating in the BLUEBERRY project.

## TODO

- [ ] Autmaticaly after installation?
- [ ] Add `start-node.sh` and `stop-node.sh` scripts
- [ ] Add a job to the crontab to start the node on boot
- [ ] Add option to use Docker version of the OMOP database (no SSH tunneling required)
- [ ] Update this README

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

The scripts are designed to run on an Oracle Linux 8 Machine (server edition). During installation it requires internet access to download the necessary packages.

Install git:
```
sudo dnf update -y
sudo dnf install git -y
```

### Installing

To get started with these scripts, follow these steps:

1. Clone this repository to your local machine: `git clone https://github.com/IKNL/v6-blueberry-installation-scripts.git`
3. Navigate to the cloned repository: `cd vantage6-blueberry-installation-scripts`
4. Run the `install-all.sh` script: `sudo ./install-all.sh`

### Details
This scripts will install the following components:

- Docker
- Miniconda
- vantage6-node

It will configure a `conda` environment `vantage6` for the vantage6-node and install the necessary packages. Once the installation is complete, a vantage6-node will be configured. The script will prompt you to enter the following information:

- `API_KEY`

The script will create a new linux user `vantage6-node` that has no `sudo` privileges.

* This user is used to connect to the host machine from the vantage6 node. This is required for the vantage6 node in order to be able to connect to the OMOP database which runs at the host machine.
* A private/public key pair is generated for this user. The public key is added to the `authorized_keys`.
* The private key of the `vantage6-node` user is mounted into the vantage6-node container.

## License

This project is licensed under the License - see the [LICENSE](LICENSE) file for details