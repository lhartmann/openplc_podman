# openplc_podman
Podman/docker container for running OpenPLC Editor.

(OpenPLC)[https://openplcproject.com/] is a IEEC61131 compatible IDE+runtime framework based on (Beremiz)[https://beremiz.org/]. At the time of writing
this tool it is problematic with several legacy python2.7 dependencies, making it unstable on modern distributions. This repository is used to build an run  OpenPLC Editor on any linux distribution using podman containers.

On the host, just clone this repository and run `run.sh`. This will:
* Build a podman container using instructions from `Dockerfile`.
  * Ubuntu 18.04 with python 2.7.
  * OpenPLC Editor.
  * openssh server for X access.
* Generate ssh id_rsa on the host, if not present.
* Start the container.
* Update known_hosts introducing the container.
* Connect to the container via SSH, and execute beremiz.
* Wait until beremiz closes.
* Stop and remove the container.

User home is mounted under /home, read-write, so projects can be saved.

## Pending Improvements
* Use separate id_rsa.* and known_hosts files to avoid risk of interference with users keys.
* Make the /home mountpoint more obvious inside the container so it does not have to be explained here.
