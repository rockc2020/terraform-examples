image:
  tag: v1.20.3

affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: kubernetes.io/hostname
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: aws-cluster-autoscaler

autoDiscovery:
  clusterName: ${clusterName}

awsRegion: ${awsRegion}

extraArgs:
  skip-nodes-with-local-storage: false
  expander: priority
  scale-down-utilization-threshold: 0.8

rbac:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${serviceAccountRoleArn}
    name: ${serviceAccountName}

replicaCount: 1
