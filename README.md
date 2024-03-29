# Docker netem agent

`netem-agent` is a container that artificially slows down a Docker network.
I use it to test the behavior of distributed systems when exposed to real-world networking conditions.

- Easily emulate properties of WANs in a Docker network via
  [`netem`](http://man7.org/linux/man-pages/man8/tc-netem.8.html)
  - Delay packets with jitter
  - Introduce packet loss, reordering, etc.
- Works in Swarm mode, Requires no special preparation of the target containers
  - Unlike e.g. [`pumba`](https://github.com/alexei-led/pumba), a powerful chaos-testing tool
    which needs the `iproute2` package in the target containers.
- Relies on standard Linux tooling

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
- Running as regular Docker container, not Swarm service

Example:
```shell
docker run -it --rm \
  --name netem-agent \
  --cap-add=NET_ADMIN \
  --privileged \
  --net=host \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /var/run/docker/netns:/var/run/netns:ro \
  terorie/netem-agent \
  --name='^dummy.*' \
  --delay=100ms \
  --jitter=50ms
```

### Options

- `--interval` Update interval
- `--name` Container name regex filters
  (optional, by default delaying all containers)
- `--delay` Outgoing packets delay
- `--jitter` Delay jitter
- `--delete` Delete all delays and exit

## Attributions

- [dockerveth](https://github.com/micahculpepper/dockerveth/tree/develop)
  for getting the `veth` interfaces of containers
- [miller](https://github.com/johnkerl/miller) for crafting with CSV
- Developed at Nimiq for testing of the [Albatross network](https://github.com/nimiq/core-rs-albatross)
