# Doppler Swarm

Here we will store the configuration of our experimental Docker Swarm Architecture.

And probably here will define the image for _Doppler Swarm Proxy_ with the required configuration.

## Architecture

Draft:

![Doppler Swarm Network](docs/doppler-swarm-network.svg)

Probably, we will sign most of the requests in _doppler-swarm-proxy_, so _doppler-for_shopify_ and
_doppler-webapp_ are only exposing non-encrypted ports.

But, _doppler-forms_ has to deal with different and non-static keys, for that reason it is also
exposing a encrypted port.
