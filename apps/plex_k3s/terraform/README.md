# Deploy Plex into K3S
`terraform init`
`terraform plan` - Review if that is what you want to achieve
`terraform appl` - To make it so

# Review
```
# kubectl get pods | grep plex
plex-5fd679494d-6jqs2    1/1     Running       0             2m1s
plex-5fd679494d-9q85j    1/1     Running       0             2m1s
plex-5fd679494d-9wbh6    1/1     Running       0             2m1s

# kubectl get services | grep plex
plex-service   LoadBalancer   10.43.248.47    192.168.75.81   32400:30848/TCP   2m36s


```

