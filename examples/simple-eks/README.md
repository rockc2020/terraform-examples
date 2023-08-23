# Cilium CNI Migration from AWS VPC CNI
This is an example for how to migrate AWS VPC CNI to Cilium CNI in an EKS cluster with zero downtime.
More details can be found in the post: [Migrate to Cilium from Amazon VPC CNI with Zero Downtime](https://medium.com/codex/migrate-to-cilium-from-amazon-vpc-cni-with-zero-downtime-493827c6b45e).

All the scripts and codes in this example is running on MacOS.

## Prerequisites
The following command line tools need to be installed on the MacOS:
* terraform
* awscli
* jq
* kubectl
* docker - only needed if you want to run terrafrom inside a container

## Step 1 - Provision an EKS cluster
```bash
make step1
```
It creates the basic environments for this example, including a VPC and subnetes, an EKS cluster with an autoscaling node group and some K8s addons.

*Note: **coredns** might be stuck during the terraform apply. If so, Control+C to cancel the command and run `make step1` again.*

## Step 2 - Labelling the K8s nodes
```bash
make step2
```
It adds a label `cni=aws` to existing nodes.

## Step 3 - Patch `aws-node` DaemonSet
```bash
make step3
```
It patches the DaemonSet of `aws-node` (VPC CNI) to run on the nodes with the label `cni=aws` only.

After this step, verify the following `nodeAffinity` content in the DaemonSet of `aws-node`.
```yaml
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: cni
                    operator: In
                    values:
                      - aws
```

## Step 4 - Install Cilium CNI
```bash
make step4
```
It installs Cilium including agents and operators. The Cilium agent only runs on nodes without the label `cni-aws`.

The configuration of Cilium in this example is basic and only for demo purpose.

After this step, the DaemonSet of `cilium` should include 0 pods.

## Step 5 - Refresh all existing K8s nodes
It needs to refresh all existing nodes with the label `cni=aws` which could be draining the nodes one by one. The cluster autoscaler could launch new nodes automatically.

*Note: If there is only one node in a simple cluster, the pod of cluster autoscaler might be pending after draining the node, so it cannot launch a new node. Then it might need to launch a new node manually from AWS autoscaling group console.*

The newly launched nodes don't have the label `cni=aws` so VPC CNI (`aws-node`) won't run while the Cilium CNI runs on them.
