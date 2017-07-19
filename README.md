# Build and import a GitHub Enterprise image for Triton

This script will download a .qcow2 GitHub Enterprise image, convert it
to a Triton-friendly format and import it into your Triton installation.

*NOTE: This script must be run on a Triton compute node with sufficient
privileges to run `vmadm` and `sdc-imgadm`*

1. Clone this repo and all submodules (e.g. `git clone --recursive …`)
1. Update the value of `GITHUB_VERSION` in `build.sh` to reflect the version
   you want to build
1. Run `./build.sh`