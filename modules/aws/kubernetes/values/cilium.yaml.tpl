cluster:
  name: ${cluster_name}
eni:
  enabled: true
ipam:
  mode: eni
egressMasqueradeInterfaces: eth0
tunnel: disabled
agentNotReadyTaintKey: ignore-taint.cluster-autoscaler.kubernetes.io/cilium-agent-not-ready
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: cni
          operator: NotIn
          values:
          - aws
rollOutCiliumPods: true
ipv4NativeRoutingCIDR: 10.0.0.0/8

operator:
  rollOutPods: true
  replicas: 1
