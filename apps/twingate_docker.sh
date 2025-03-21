# Vernify.twingate.com
docker run -d \
    --sysctl net.ipv4.ping_group_range="0 2147483647" \
    --env TWINGATE_NETWORK="vernify" \
    --env TWINGATE_ACCESS_TOKEN="" \
    --env TWINGATE_REFRESH_TOKEN=""  \
    --env TWINGATE_LABEL_HOSTNAME="`hostname`" \
    --env TWINGATE_LABEL_DEPLOYED_BY="docker" \
    --name "twingate-tungsten-skunk" \
    --restart=unless-stopped \
    --pull=always \
    twingate/connector:1
