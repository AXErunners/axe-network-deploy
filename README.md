# AXE Network Deployment Tool

## Introduction

This tool allows deploy and manage [AXE](https://github.com/AXErunners/axe) networks.

There are two regular available networks: `testnet` and `mainnet`.
After deployment your AxeCore instances will join to those networks.

`regtest` and `devnet-*` are networks for testing purposes.
Devnet are like regular Axe networks (`mainnet` and `testnet`)
but easier to bootstrap and has own name. That's why it easier to have multiple in parallel.  

Work in progress and in its initial state only meant to be used by Axe Core
developers to assist in Axe Evolution development.

## Installation

1. [Install Docker](https://docs.docker.com/install/)
2. Download tool:

    Using `wget`:

    ```bash
    wget -P /usr/local/bin https://raw.github.com/axerunners/axe-network-deploy/master/bin/axe-network && \
    chmod +x /usr/local/bin/axe-network
    ```

    Using `curl`:

    ```bash
    curl -fsSL -o /usr/local/bin/axe-network https://raw.github.com/axerunners/axe-network-deploy/master/bin/axe-network && \
    chmod +x /usr/local/bin/axe-network
    ```


## Configuration

### Credentials

Configure your credentials in `.env` file.
Use [.env.example](https://github.com/axerunners/axe-network-deploy/blob/master/examples/.env.example) as example.

### Networks definition

Please find examples of network configurations
in [examples directory](https://github.com/axerunners/axe-network-deploy/tree/master/examples/).

Name of files are equal to Axe network names.

Terraform configuration defined in `*.tfvars` files.
All available options you will find
in [variables.tf](https://github.com/axerunners/axe-network-deploy/blob/master/terraform/aws/variables.tf) file.

Ansible configuration in `*.yaml` files.
[group_vars/all](https://github.com/axerunners/axe-network-deploy/blob/master/ansible/group_vars/all)
file contains the majority of playbook options.
The rest of them defined in [ansible roles](https://github.com/axerunners/axe-network-deploy/tree/master/ansible/roles).

### Using git

Please don't forget to include in your `.gitignore`:
```
.env
*.inventory
*.ovpn
```

## Deployment

To deploy Axe Network use `deploy` command with particular network name:

```bash
axe-network deploy <network_name>
```

You may pass `--only-infrastructure` or `--only-provisioning` option to avoid to do a particular type of work.

To destroy available Axe Network use `destroy` command:

```bash
axe-network destroy <network_name>
```

You may pass `--keep-infrastructure` option to remove software and configuration and keep infrastructure.

## List network services

```bash
axe-network list <network_name>
```

## Testing

To test network run `test` command with with particular network name:

```bash
axe-network test <network_name>
```

You may pass `--type` option to run particular type of tests (`smoke`, `e2e`).
It possible to specify several types using comma delimiter.

## Deploy Axe Evolution

1. Deploy your network with additional ansible variables:

    ```yaml
    evo_services: true
    insight_image: "<docker-image>"
    drive_image: "<docker-image>"
    dapi_image: "<docker-image>"
    axed_image: "<docker-image>"
    # uncomment if docker images stored in AWS ECR
    # aws_ecr_login: true
    ```

2. Get current block height:

    ```bash
    docker run -ti --rm \
               -v "$PWD:/networks" \
               -v "$HOME/.aws:/root/.aws" \
               -v "<your-public-key-path>:<your-public-key-path>" \
               -v "<your-private-key-path>:<your-private-key-path>" \
               -w "/usr/src/app/ansible" \
               axerunners/axe-network-deploy ansible axed-wallet-2 \
               -i ../networks/<network_name>.inventory \
               --private-key=<your-private-key-path> \
               -b -m command -a "axe-cli getblockcount"
    ```


3. Enable Masternode List after ten new blocks:

    ```bash
    docker run -ti --rm \
                   -v "$PWD:/networks" \
                   -v "$HOME/.aws:/root/.aws" \
                   -v "<your-public-key-path>:<your-public-key-path>" \
                   -v "<your-private-key-path>:<your-private-key-path>" \
                   -w "/usr/src/app/ansible" \
                   axerunners/axe-network-deploy ansible axed-wallet-2 \
                   -i ../networks/<network_name>.inventory \
                   --private-key=<your-private-key-path> \
                   -b -m command -a "axe-cli spork SPORK_15_DETERMINISTIC_MNS_ENABLED <current_block_height+10>"
    ```

4. Upgrade your MNs to ProTX when DIP3 is enabled
  (see [getBlockChainInfo](https://axe-docs.github.io/en/developer-reference#getblockchaininfo)):

   ```bash
   axe-network deploy -p --ansible-playbook=upgrade-to-protx <network_name>
   ```

## Connect to private Axe Network services

You can use generated during deployment OpenVPN config `<network_name>.ovpn` to connect to private services.

## Manual installation

1. Clone git repository:

    ```bash
    git clone https://github.com/axerunners/axe-network-deploy.git
    ```

2. Install Ansible and Terraform per instructions provided on official websites:

    * [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
    * [Terraform](https://www.terraform.io/intro/getting-started/install.html)

3. Ensure Python netaddr package installed locally

    ```bash
    pip install -U netaddr
    ```

    * Note: You may need to run the above command with "pip2" instead of "pip" if
      your default Python installation is version 3 (e.g. OSX + Homebrew).

4. Install pre-requisite Ansible roles

    ```bash
    ansible-galaxy install -r ansible/requirements.yml
    ```

5. Install [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)


6. Install [Node.JS](https://nodejs.org/en/download/) and dependencies:

    ```bash
    npm install
    ```

7. Install OpenVPN:

    On Linux:
    ```bash
    apt-get install openvpn
    ```

    On Mac:
    ```bash
    brew install openvpn
    ```
