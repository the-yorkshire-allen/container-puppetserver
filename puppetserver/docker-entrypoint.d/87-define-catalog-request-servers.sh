#!/bin/bash

set -e

if [ -n "${CATALOG_REQUEST_SERVERS}" ]; then
    /opt/puppetlabs/puppet/bin/ruby /add_catalog_compilers_to_auth.rb -h "${CATALOG_REQUEST_SERVERS}"
fi

if [ -n "${REPORT_REQUEST_SERVERS}" ]; then
    /opt/puppetlabs/puppet/bin/ruby /add_report_servers_to_auth.rb -h "${REPORT_REQUEST_SERVERS}"
fi
