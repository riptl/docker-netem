# Docker netem agent

- Easily emulate properties of WANs in a Docker network via
  [`netem`](http://man7.org/linux/man-pages/man8/tc-netem.8.html)
  - Delay packets with jitter
  - Introduce packet loss, reordering, etc.
- Works in Swarm mode, Requires no special preparation of the target containers
  - Unlike e.g. [`pumba`](https://github.com/alexei-led/pumba), a powerful chaos-testing tool
    which needs the `iproute2` package and `NET_ADMIN` privilege in the target containers.
  - `--cap-add=NET_ADMIN` on services is impossible with Docker Swarm
    (https://github.com/moby/moby/issues/25885). `docker-netem` works around this.
- Relies on standard Linux tooling
- Light alpine container

### How does it work?

It uses [dockerveth](https://github.com/micahculpepper/dockerveth/tree/develop)
in the host network context to map all selected containers to their `veth` interfaces.

Then, it activates the NetEm traffic control facilities on those interfaces.

## Configuration

Requirements:
- Linux machine
- Preparation of target containers _not_ required
- Access to the Docker daemon
- `NET_ADMIN` capability on agent and elevated privileges
  (TODO Make it work with less privileges)
- Access to Docker network namespaces
- Host networking enabled on agent
- Running as regular Docker container, not service

Example:
```shell
docker run -d \
  --name netem-agent \
  --cap-add=NET_ADMIN \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /var/run/docker/netns:/var/run/docker/netns:ro \
  terorie/netem-agent \
  --name='^devnet_validator' \
  --delay=100ms \
  --jitter=50ms
```

### Options

- `--name` Container name regex filters
  (optional, by default delaying all containers)
- `--delay` Outgoing packets delay
- `--jitter` Delay jitter

## Attributions

- [dockerveth](https://github.com/micahculpepper/dockerveth/tree/develop)
  for getting the `veth` interfaces of containers
- [miller](https://github.com/johnkerl/miller) for crafting with CSV
- Developed at Nimiq for testing of the [Albatross network](https://github.com/nimiq/core-rs-albatross)
