#!/bin/zsh

general_cleanup() {

  # Tag all attribute lines for removal that match a general pattern of being empty, ie: null, empty maps, empty quotes, etc.

  sed -i '' -e '/^resource "aws_vpc"/,/^}/s/^.*null/REMOVED/' ${1}
  sed -i '' -e '/^resource "aws_vpc"/,/^}/s/^.*{}/REMOVED/' ${1}
  sed -i '' -e '/^resource "aws_vpc"/,/^}/s/^.*\"\"/REMOVED/' ${1}
  sed -i '' -e '/^resource "aws_vpc"/,/^}/s/^.*\[\]/REMOVED/' ${1}

}

aws_vpc_cleanup() {

  # Tag resource specific lines for removal that are set to default vaules
 
  echo "Starting AWS VPC cleanup"
   
  for file in `find *.tf`; do
  
    # Create a backup of the original file
    cp ${file} ${file}.original

    general_cleanup ${file}


    sed -i '' -e '/^resource "aws_vpc"/,/^}/s/^.*\=[[:space:]]0/REMOVED/' ${file}
    sed -i '' -E '/^resource "aws_vpc"/,/^}/s/^[[:space:]]*assign_generated_ipv6_cidr_block[[:space:]]*=[[:space:]]*false[[:space:]]*$/REMOVED/' ${file}
    sed -i '' -E '/^resource "aws_vpc"/,/^}/s/^[[:space:]]*enable_dns_hostnames[[:space:]]*=[[:space:]]*false[[:space:]]*$/REMOVED/' ${file}
    sed -i '' -E '/^resource "aws_vpc"/,/^}/s/^[[:space:]]*enable_network_address_usage_metrics[[:space:]]*=[[:space:]]*false[[:space:]]*$/REMOVED/' ${file}
    sed -i '' -E '/^resource "aws_vpc"/,/^}/s/^[[:space:]]*instance_tenancy[[:space:]]*=[[:space:]]*"default"[[:space:]]*$/REMOVED/' ${file}


    # Delete all the lines that were tagged for removal due to default values
    
    sed -i '' -e '/REMOVED/d' ${file}

  done

  echo "Finished AWS VPC cleanup"

}

aws_vpc_cleanup
