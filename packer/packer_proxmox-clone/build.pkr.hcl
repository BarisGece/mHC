# Files need to be suffixed with '.pkr.hcl' to be visible to Packer.
# To use multiple files at once they also need to be in the same folder.
# 'packer inspect folder/' will describe to you what is in that folder.

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build

build {
  sources = ["sources.proxmox-clone.mhc"]
}