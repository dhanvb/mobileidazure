# MobileID in Azure Cloud Platform

This repository consists of the infrastructure and deployment model of MobileID for the Azure Cloud Platform, implemented with [Terraform](https://www.terraform.io).

* [Overview](#development-diagram)
  * [Kubernetes](#kubernetes)
  * [RabbitMQ](#rabbitmq)
  * [PostgresQL Database Server](#postgresql-database-server)
* [General Project structure](#general-project-structure)
* [Usage](#usage)
* [Pipeline](#pipeline)
* [Resources created](resources-created)


## Overview

![architecture diagram](/resources/arch.png)

MobileID consists of main services: a [Kubernetes](https://kubernetes.io) cluster and a [PostgresQL](https://www.postgresql.org) database server. It is possible to delivery all three environments at once or one per branch (current configuration), where:

Branch name | Azure environment
--- | ---
develop | dev
qa | qa
main | stg

If the one at once option is choosen the TF_VAR_environments key must receive an array like this: ["dev", "qa", "stg"]. It is not possible to create other type of environment.

## Kubernetes

In the Kubernetes cluster we will have two nodes per region: a linux and a windows. 

The applications running on the linux node are:
- Keycloak
- Backoffice
- Gateway
- Postgres Database
- Liveness

The applications running on the windows node are:
- Match service (for while it is running on a container instance not in the kubernetes)

Along with the gateway there's also a job deployed called "gateway-migrations", which performs the migrations necessary for its database before the Gateway starts. This is needed because there can be several gateway's running at the same time. If all of these owned the data migration and performed it on startup, it would originate race conditions, and the possibility of corrupting the database.

All these images will be fetched from Mobile ID's team docker registry present in Azure.

Note: biometric service is running aside of kuebernete cluster due to container runtime technology type where docker runtime is being deprecated and biometric service, which runs on a windows node type, onle runs with docker runtime.


## RabbitMQ

In order to allow asyncronous communication, this project uses RabbitMQ as a broker message resource which develivery messages to many consumers. Subject service will push messages into a queue and then consumers can read those messages and process in any time allowing a better and faster solution for enrollment.
RabbitMQ configuration can be achieved by a file called rabbitma-configuration.yml located in resources folder. See the below example:

``` yaml

exchanges:
  - name: &exchanges0 subjects-exchange
    settings:
      type: topic
      durable: false
      auto_delete: true
queues:
  - name: &queues0 subjects.consumer.lisbon
    settings:
      durable: true
      auto_delete: true
  - name: &queues1 subjects.consumer.faro
    settings:
      durable: true
      auto_delete: true
bindings:
  - source: *exchanges0
    destination: *queues0
    destination_type: queue
    routing_key: "#.lisbon"
  - source: *exchanges0
    destination: *queues1
    destination_type: queue
    routing_key: "#.faro"
  - source: *exchanges0
    destination: *queues0
    destination_type: queue
    routing_key: "air-asia.nobcbp.nobcbp"

```

To have a better understanding about this solution see [CloudAMPQ](https://www.cloudamqp.com/) site and [RabbitMQ](https://www.rabbitmq.com/).

## PostgresQL Database Server

There will be one database present in this server: API, which is the gateway's database.
For the API, there's two users associated: api, and apimigrator. API migrator will be used by the gateway's migrations job, and has full permissions. The API on the other hand, has more restricted permissions and is used by the gateway.


## General Project Structure
```bash
.
└── tf/
    ├── modules/
    |   ├── aks/
    |   ├── base/
    |   ├── certificate/
    |   ├── cloudamqp/
    |   ├── db/
    |   ├── db-server/
    |   ├── dns/
    |   ├── ingress/
    |   └── kubernets/
    |   └── nat-gateway/
    |   └── rabbitmq/
    └── src/
        ├── broker/
        ├── infra/
        ├── kubernetes/
        └── variables.yml    
```

The major of folders contains three main files: 

- main.tf: contains the main set of configuration for your module such as required providers, required version and others.
- output.tf: contains the output definitions for your module. Module outputs are made available to the configuration using the module, so they are often used to pass information about the parts of your infrastructure defined bY the module to other parts.
- variables.tf: contains the variable definitions for your module. When your module is used by others, the variables will be configured in the module block.


### Modules
- aks: it is a module that configures all AKS (Azure Kubernetes Service) cluster parameters, such as: resource name, resource group name, region etc.
- base: it creates and configures several basic resources such as: virtual network, analytics and resource group.
- certificate: it communicates with letsencrypt which will issue certificates for cluster.
- cloudamqp: creates CloudAMQP resources such as instances.
- db: it sets and configures gateway's database for each environment.
- db-server: it creates and configures an instance of a Postgres database server with parameters such as: storage size, administrator login and password, resource group etc.
- dns: creates DNS zones for each environment.
- ingress: allows outter request reach cluster services.
- kubernetes: configures the required services into the cluster. Configured pods:
    - backoffice [dev, qa, stg].
    - gateway [dev, qa, stg]. Also configures a job to run database migration.
    - keycloak [shared resource]
    - liveness [shared resource]
- nat-gateway: configures nat grateway in order to make outbound calls such as data flow injection.
- rabbitmq: creates RabbitMQ resources such as bindings, queues, exchanges etc.


### Src
- infra: configures all the above modules together, the linux and windows virtual machines size, node count etc. It also configures the match service as aside application as described above.
- kubernetes: configures the k8s cluster with all the environment variables.


### Variables

General configurations such as linux vm size, postgres version, region etc.

Variable | Description
--- | ---
client | Client's name. No spaces allowed.
region | East Asia.
dns | Base domain.
postgres_version |Database's postgres version. Major versions only.
db_storage_size | The size of the data disk, in GB.
db_sku | Specifies the SKU Name for the db server.
db_backup_retention_days | Backup retention days for the server.
high_availability | A boolean indicating if the database has high availability.
k8s_linux_node_count | Linux node pool's node count.
k8s_linux_vm_size | Linux node vm size.
k8s_windows_node_count | Windows node pool's node count.
k8s_windows_vm_size | Windows node vm size.
k8s_dns_prefix | DNS prefix specified when creating the managed cluster.
liveness_replicas | Number of liveness pod's replicas.
liveness_version | Liveness' image version.
keycloak_dns_name | Keycloak's DNS name.
keycloak_version | Keycloak's image version.
gateway_dns_name | Gateway's DNS name. 
gateway_version | Gateway's image version.
gateway_replicas | Number of gateway pod's replicas.
backoffice_dns_name | Gateway's DNS name.
backoffice_version | Backoffice's image version.
match_service_version | Match service's image version.
cloudamq_instances | Array of CloudAMQP instances by environment which contains the environment name and plan.
cloudamq_region | CloudAMQP region where the instance will run.


## Usage

In order to deploy the environments some CI/CD variables must be configured as described below:

Variable | Description
--- | ---
ARM_SUBSCRIPTION_ID | GUID that identifies your subscription.
ARM_CLIENT_ID | Identity created under Azure Active Directory.
ARM_CLIENT_SECRET | Identity secret.
ARM_TENANT_ID | Service principal identity for gitlab.
TF_VAR_container_registry_name | The docker images registry server. 
TF_VAR_container_registry_password | The docker images registry server password. 
TF_VAR_container_registry_username | The docker images registry server username. 
TF_VAR_dev_container_registry_name | The docker images registry server for dev and qa environments. 
TF_VAR_dev_container_registry_password |  The docker images registry server password for dev and qa environments.
TF_VAR_dev_container_registry_username | The docker images registry server username for dev and qa environments. 
TF_VAR_azure_storage_account_name | The name for the Azure Storage used by the gateway. This value must be provided by the MobileID team. 
TF_VAR_azure_storage_account_key | The key for the Azure Storage used by the gateway. This value must be provided by the MobileID team. 
TF_VAR_liveness_api_key | The key for the liveness service. This value must be provided by the MobileID team. 
TF_VAR_admin_ssh_key_data | A ssh key provided to configure cluster linux profile.
TF_VAR_environments | Array of environments (dev, qs and/or stg) used to create the infrastructure. Default value is dev and it is configured by branch.
TF_VAR_cloudamqp_apikey | CloudAMQP api key to create instances.
TF_VAR_cloudamqp_endpoint | CloudAMQP administrative endpoint to allows resource creation.

The deployment will generate all environments (dev, qa, stg) at once. After deployment, it will create three DNS zones with 4 name servers each, which will feed our DNS Zone Project for delegation pourposes, that can be seen [here](https://git.intra.vision-box.com/mobile-id/infra/deployment-mobile-id-dns-azure-terraform).

Example of created DNS zones and name servers:

- dev.mobileid.vb-services-dev.net
  - ns1-07.azure-dns.com.
  - ns2-07.azure-dns.net.
  - ns3-07.azure-dns.org.
  - ns4-07.azure-dns.info.
- qa.mobileid.vb-services-dev.net
  - ns1-08.azure-dns.com.
  - ns2-08.azure-dns.net.
  - ns3-08.azure-dns.org.
  - ns4-08.azure-dns.info.
- stg.mobileid.vb-services-dev.net
  - ns1-04.azure-dns.com.
  - ns2-04.azure-dns.net.
  - ns3-04.azure-dns.org.
  - ns4-04.azure-dns.info.


## Pipeline

Terraform generates a state file to keep track of the infrastructure, and what changes must be done. This is stored in gitlab itself on merge request pipelines. It can be consulted by clicking on "Infrastructure" on the side bar, and then "Terraform". Since, for security reasons, most of the passwords are being generated randomly, the only way to know these values is to download the state file. **It is recommended that before accepting a merge request the state file should be reviewed, since there can be destructive actions that are not intended.**

The pipeline performs a security validation using [checkov](https://www.checkov.io). It's possible to check the tests performed and its results by clicking on the pipeline id, and then the tests tab. If a test fails, refer to this [page](https://docs.bridgecrew.io/docs/azure-policy-index) for validation.

A json report of the current cost of the infrastructure using Infracost is being saved on each pipeline as an artifact. On the main page of the pipeline's status, click on the ellipsis of the desired pipeline and download the costs artifact.

In order to make the pipeline run successfully and delivery all necessary resources, it is mundatory that the Registered Application, in this case GilabAzure, must have the next permissions:
![api permissions](/resources/api-permissions.png)

## Possible errors
The pipeline sometimes can throw error at the last step (deploy-kubernetes), if it creates the cluster from scratch, due to issue certificates part because cluster is not ready to do that. It it happens, just relaunch the last step, in the future all the pipeline steps must be reviewed.
Some created resources are not available in all azure regions, thats why North Europe was choosen as default region.

## Nat Gateway
In order to make connection to a FLow Data Injection in a private network it is needed to make outbound calls from k8s cluster through the Nat Gateway via public IP. To test this configuration, first you need to connecto into the cluster through any console tool and then execute next steps:

- kubectl run --rm -it ubuntu -n default --image ubuntu:latest /bin/bash
- apt update && apt install curl --yes
- curl http://ipv4.icanhazip.com  

If you get IPs inside configured range (defined in "prefix_length" property of resource "azurerm_public_ip_prefix") everything went well.

## Resources Created

At the end of the pipeline execution, it will create several resources withing a Resource Group (called `mobileid-visionbox-dev`):

- DNS Zones as described before (dev, qa and stg)
- Container instance 
- Azure Database for PostgreSQL
- Kubernetes service
- Virtual network
