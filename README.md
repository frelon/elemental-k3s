# Run a simple elemental k3s cluster

To boot a machine:

```
sudo ./add_br.sh <interface name>
sudo make REPO=<my repository> ISO_REPO=<my repository> build
sudo -E ./run.sh
```

Once booted from the ISO login with `root`/`cos` and install the system with:

```
elemental install --debug --reboot --system.uri=<my repo> /dev/sda
```

