# Azure CycleCloud Lustre

Lustre is a High Performance Parallel Filesystem typically used for High Performance Computing.  This repository contains an Azure CycleCloud project and templates to create a lustre file system on Azure.

This Lustre filesystem project is designed for either ephemeral scratch data and uses [Dds_v4](https://docs.microsoft.com/en-us/azure/virtual-machines/ddv4-ddsv4-series#ddsv4-series) virtual machines that have local SSD disks.  The SSD disk in the virtual machine will be used as the OST.  Please consider the [network throughput](https://docs.microsoft.com/en-us/azure/virtual-machines/ddv4-ddsv4-series#ddsv4-series) when choosing the VM size as the bottleneck for this setup is the network.  It is recommended to use the D64ds_v4 as the OSS to use the full machine.

Version 1.4 added in an option to create a durable scratch filesystem using 10 Premium SSDs in RAID 0.  The total size of the OST is defined in the CycleCloud cluster settings and each disk is 1/10th of the total (ie. 10GB OST size will use 10 1GB SSD).

## Cluster Life-Cycle for Premium Disk

It is possible to delete data and disks managed by CycleCloud in the CycleCloud UI.
This can result in data loss.  Here are the actions available in the CycleCloud management.

* Create Cluster - creates storage VMs and disks
* Add Node - add additional node will increase size & resources of cluster
* Shutdown/Deallocate Node - will suspend node but preserve disks.
* Start Deallocated Node - restore data and resources of deallocated node.
* Shutdown/Delete Node - delete VM and disks, data on disks will be destroyed.
* Terminate Cluster - delete all VMs and disks, all data destroyed.

It is possible to create a LFS cluster, populate the data and when the workload
is finished, deallocate the VMs so that the cluster can be restarted.
This is helpful in controlling costs, because charges for the VMs will be suspended while
deallocated.  Keep in mind that disks will still accrue charges while the VMs are 
deallocated.

![CC VM Deallocate](/images/deallocate.png "Preserve data by deallocating VMs")

## Hierarchical Storage Manager (HSM)

The project has an option to use [HSM](https://github.com/edwardsp/lemur) where data can be imported and archived to [Azure BLOB storage](https://azure.microsoft.com/en-gb/services/storage/blobs/).  All nodes run the HSM daemon when enabled.


## Monitoring

Monitoring can be enabled where the following metrics will be written to [Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/log-query/get-started-portal#meet-log-analytics):

* Load Average
* Kilobytes Free
* Network Bytes Sent
* Network Bytes Received


## Lustre Versions

The Lustre versions that are currently supported are `2.10` and `2.12`.  Make sure that the filesystem and clients all use the same version.  The [Whamcloud](https://downloads.whamcloud.com/public/lustre/) repository is used for RPMs and so you must use version `2.10` for CentOS 7.6 and `2.12` for CentOS 7.7.

> Note: The Lustre configuration scripts are from [here](https://github.com/Azure/azurehpc/tree/master/scripts).  If the [AzureHPC](https://github.com/Azure/azurehpc) is checked out an installed there is a script, `update_lustre_scripts.sh`, that will update the cycle template with the latest versions.

# Installation

Below are instructions to check out the project from github and add the lfs project and template:

```
git clone https://github.com/grandparoach/cyclecloud-lfs
cd cyclecloud-lfs
cyclecloud project upload <container>
cyclecloud import_template -f templates/lfs.txt
```

An extended PBSpro template is included in this repository with the option for choose a Lustre filesystem to set up and mount on the nodes:

```
cyclecloud import_template -f templates/pbspro.txt
```

> Note: The PBSpro template a modified version of the official one [here](https://github.com/Azure/cyclecloud-pbspro/blob/master/templates/pbspro.txt)

An extended Slurm template is included in this repository with the option to choose a Lustre filesystem to set up and mount on the nodes:

```
cyclecloud import_template -f templates/slurm-lfs.txt

Now, you should be able to create a new "lfs" cluster in the Azure CycleCloud User Interface.  Once this has been created you can create PBS cluster and, in the configuration, select the new file system to be used.

# Extending a template to use a Lustre filesystem

The node types only need the following additions:

```
[[[configuration]]]
lustre.cluster_name = $LustreClusterName
lustre.version = $LustreVersion
lustre.mount_point = $LustreMountPoint

[[[cluster-init lfs:client]]]
```

These variables (`LustreClusterName`, `LustreVersion` and `LustreMountPoint`) can be parameterized and given an additional `Lustre Setttings` configuration section by appending the following to the template:

```
[parameters Lustre Settings]
Order = 25
Description = "Use a Lustre cluster as a NAS. Settings for defining the Lustre cluster"

    [[parameter LustreClusterName]]
    Label = Lustre Cluster
    Description = Name of the Lustre cluster to connect to. This cluster should be orchestrated by the same CycleCloud Server
    Required = True
    Config.Plugin = pico.form.QueryDropdown
    Config.Query = select ClusterName as Name from Cloud.Node where Cluster().IsTemplate =!= True && ClusterInitSpecs["lfs:default"] isnt undefined
    Config.SetDefault = false

    [[parameter LustreVersion]]
    Label = Lustre Version
    Description = The Lustre version to use
    DefaultValue = "2.10"
    Config.FreeForm = false
    Config.Plugin = pico.control.AutoCompleteDropdown
        [[[list Config.Entries]]]
        Name = "2.10"
        Label = "2.10"
        [[[list Config.Entries]]]
        Name = "2.12"
        Label = "2.12"
    
    [[parameter LustreMountPoint]]
    Label = Lustre Mount Point
    Description = The mount point to mount the Lustre file server on.
    DefaultValue = /lustre
    Required = True
```

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
