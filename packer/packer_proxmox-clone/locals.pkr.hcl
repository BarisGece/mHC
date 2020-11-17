# Local Variables and Type Constraints
# https://www.packer.io/guides/hcl/variables#defining-variables-and-locals
# https://www.packer.io/docs/from-1.5/variables#type-constraints for more info.
# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }