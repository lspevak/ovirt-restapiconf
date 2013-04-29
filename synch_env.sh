#! /bin/bash
#
# Copyright (c) 2013 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# oVirt environment synchronization routines
#
# required utilities: xmllint, curl

# configuration of the oVirt engine
ENGINE_URL="http://localhost:8700"
USER_NAME="admin@internal"
USER_PASSW="YOUR_PASSWORD"
# CA certificate path
CA_CERT_PATH=""

DIR=`dirname $0`
source ${DIR}/rest_api_routines.sh

echo "Current status..."
getDataCenters
getClusters
getHosts
getVirtualMachines

echo "Synchronizing configuration..."
createHost "server1.example.com" "192.168.10.10" "123456" "Default"
createHost "server2.example.com" "192.168.10.11" "123456" "Default"

# create vs. import
createNfsDataStorage "Storage_DATA" "192.168.10.12" "/mnt/export/nfs/data" "server1.example.com"
attachStorageToDataCenter "Default" "Storage_DATA"
activateDataCenterStorage "Default" "Storage_DATA"

createNfsExportStorage "Storage_EXPORT" "192.168.10.12" "/mnt/export/nfs/export" "server1.example.com"
attachStorageToDataCenter "Default" "Storage_EXPORT"
activateDataCenterStorage "Default" "Storage_EXPORT"

importNfsIsoStorage "192.168.10.12" "/mnt/export/nfs/iso" "server1.example.com"
# supply existing name of iso domain (imported):
attachStorageToDataCenter "Default" "iso"
# supply existing name of iso domain (imported):
activateDataCenterStorage "Default" "iso"

# VM 512M, disk 10GB
createVirtualMachineFromTemplate "Fedora17_test1" "Default" "Blank" "536870912"
createVirtualMachineNIC "Fedora17_test1" "ovirtmgmt"
createVirtualMachineDisk "Fedora17_test1" "10485760000" "Storage_DATA"
# iso file must be a part of the iso domain
createVirtualMachineCDROM "Fedora17_test1" "Fedora-17-x86_64-DVD.iso"

