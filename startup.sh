#!/bin/bash

export LC_ALL=en_US.UTF-8
sudo apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -yq
sudo apt install -y p7zip-full php-cli php-xml pkg-config build-essential unzip snapd cmake autoconf libavcodec-extra libavformat57 default-jre libaio1 pixz jq

echo Begin: tested on Ubuntu Linux

# Get the instance info

# string=$(curl ipinfo.io)
string=$(lshw -C System | grep vendor)
if [[ "$${string}" == *"Google"* ]] ; then
    instanceType_tmp=$(curl http://metadata.google.internal/computeMetadata/v1/instance/machine-type -H "Metadata-Flavor: Google")
    cpuPlatform_tmp=$(curl http://metadata.google.internal/computeMetadata/v1/instance/cpu-platform -H "Metadata-Flavor: Google")
    cpuPlatform=`echo $${cpuPlatform_tmp} | sed 's/[ ][ ]*/-/g' | tr A-Z a-z`
    instanceType=$${instanceType_tmp##*\/}"-"$${cpuPlatform}
    instanceTypeOnly=$${instanceType_tmp##*\/}
    band="GCP"
    cpu_core_tmp=$(lscpu | head -n 4 | tail -n 1)
    cpu_core=$(echo $${cpu_core_tmp##*:})
    cpu_speed_tmp=$(cat /proc/cpuinfo | head -n 8 | tail -n 1)
    cpu_speed=$(echo $${cpu_speed_tmp##*:})
    mem_size_tmp=$(lshw -short -C memory | head -n 4 | tail -n 1 | awk '{print $3}')
    mem_size=$(echo $${mem_size_tmp##*:})
elif [[ "$${string}" == *"Amazon"* ]] ; then

    # # # For ARM
    # instanceType=$(curl http://169.254.169.254/latest/meta-data/instance-type/)
    # instanceTypeOnly=$${instanceType}
    # band="AWS"
    # mem_size_tmp=$(lshw -short -C memory | head -n 7 | tail -n 1 | awk '{print $3}')
    # mem_size=$(echo $${mem_size_tmp##*:})
    # cpu=$(lscpu | grep Vendor)
    # cpuPlatform=$(echo $${cpu##*:})
    # cpu_core_tmp=$(lscpu | head -n 3 | tail -n 1)
    # cpu_core=$(echo $${cpu_core_tmp##*:})
    # cpu_speed_tmp=$(lshw -C CPU | grep size | head -n 1 | tail -n 1)
    # cpu_speed=$(echo $${cpu_speed_tmp##*:}) 
    
    # For Non-ARM
    instanceType=$(curl http://169.254.169.254/latest/meta-data/instance-type/)
    instanceTypeOnly=$${instanceType}
    band="AWS"
    mem_size_tmp=$(lshw -short -C memory | head -n 7 | tail -n 1 | awk '{print $3}')
    mem_size=$(echo $${mem_size_tmp##*:})
    cpu=$(lscpu | grep name)
    cpuPlatform_tmp=$(echo $${cpu##*:})
    cpuPlatform=`echo $${cpuPlatform_tmp} | tr -d '(R)' | sed 's/ /_/g'`
    cpu_core_tmp=$(lscpu | head -n 4 | tail -n 1)
    cpu_core=$(echo $${cpu_core_tmp##*:})
    cpu_speed_tmp=$(lshw -C CPU | grep size | head -n 1 | tail -n 1)
    cpu_speed=$(echo $${cpu_speed_tmp##*:})

elif [[ "$${string}" == *"Microsoft"* ]] ; then
    band="Azure"
    instanceType_tmp=$(curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/vmSize?api-version=2020-09-01&format=text")
    location=$(curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/location?api-version=2020-09-01&format=text")
    instanceType=`echo $${instanceType_tmp} | tr A-Z a-z`
    instanceTypeOnly=$${instanceType}
    cpu=$(lscpu | grep name)
    cpuPlatform_tmp=$(echo $${cpu##*:})
    cpuPlatform=`echo $${cpuPlatform_tmp} | tr -d '(R)' | sed 's/ /_/g'`
    cpu_core_tmp=$(lscpu | head -n 4 | tail -n 1)
    cpu_core=$(echo $${cpu_core_tmp##*:})
    cpu_speed_tmp=$(lshw -C CPU | grep size | head -n 1 | tail -n 1)
    cpu_speed=$(echo $${cpu_speed_tmp##*:})
    mem_size_tmp=$(lshw -short -C memory | head -n 4 | tail -n 1 | awk '{print $3}')
    mem_size=$(echo $${mem_size_tmp##*:})

elif [[ "$${string}" == *"Alibaba"* ]] ; then
    band="Alicloud"
    instanceType_tmp=$(curl http://100.100.100.200/latest/meta-data/instance/instance-type)
    instanceType=`echo $${instanceType_tmp} | tr A-Z a-z`
    instanceTypeOnly=$${instanceType}
    cpu=$(lscpu | grep name)
    cpuPlatform_tmp=$(echo $${cpu##*:})
    cpuPlatform=`echo $${cpuPlatform_tmp} | tr -d '(R)' | sed 's/ /_/g'`
    cpu_core_tmp=$(lscpu | head -n 4 | tail -n 1)
    cpu_core=$(echo $${cpu_core_tmp##*:})
    cpu_speed_tmp=$(cat /proc/cpuinfo | head -n 8 | tail -n 1)
    cpu_speed=$(echo $${cpu_speed_tmp##*:}MHz)
    mem_size_tmp=$(lshw -short -C memory | head -n 4 | tail -n 1 | awk '{print $3}')
    mem_size=$(echo $${mem_size_tmp##*:})

elif [[ "$${string}" == *"Tencent"* ]] ; then
    band="Tencentcloud"
    instanceType_tmp=$(curl http://metadata.tencentyun.com/latest/meta-data/instance/instance-type)
    instanceType=`echo $${instanceType_tmp} | tr A-Z a-z`
    instanceTypeOnly=$${instanceType}
    cpu=$(lscpu | grep name)
    cpuPlatform_tmp=$(echo $${cpu##*:})
    cpuPlatform=`echo $${cpuPlatform_tmp} | tr -d '(R)' | sed 's/ /_/g'`
    cpu_core_tmp=$(lscpu | head -n 4 | tail -n 1)
    cpu_core=$(echo $${cpu_core_tmp##*:})
    cpu_speed_tmp=$(cat /proc/cpuinfo | head -n 8 | tail -n 1)
    cpu_speed=$(echo $${cpu_speed_tmp##*:}MHz)
    mem_size_tmp=$(lshw -short -C memory | head -n 4 | tail -n 1 | awk '{print $3}')
    mem_size=$(echo $${mem_size_tmp##*:})
fi

export TEST_RESULTS_NAME_tmp="phoronix-"$${instanceType}"-$(date +%Y-%m-%d%s)"
export TEST_RESULTS_IDENTIFIER=$${instanceType}
export TEST_RESULTS_DESCRIPTION="System benchmark using phoronix-test-suite"
export TEST_RESULTS_NAME=`echo $${TEST_RESULTS_NAME_tmp} | sed 's/\./-/g'| sed 's/\_/-/g'`


curl -L -O https://phoronix-test-suite.com/releases/phoronix-test-suite-10.6.1.tar.gz
tar -zxpf phoronix-test-suite-10.6.1.tar.gz

cd phoronix-test-suite/
PTS_SILENT_MODE=1 ./phoronix-test-suite enterprise-setup # to avoid accept the agreement everytime
echo ynyyyyyn | ./phoronix-test-suite batch-setup # initialize the parameters for batch run
phoronixRSFolder="/phoronix-test-result"

mkdir $${phoronixRSFolder}
mkdir $${phoronixRSFolder}/$${TEST_RESULTS_NAME}

echo "Run benchmarks: " ${benchmark}

echo 3 | ./phoronix-test-suite install ${benchmark}
./phoronix-test-suite batch-benchmark ${benchmark}
./phoronix-test-suite system-info > $${phoronixRSFolder}/$${TEST_RESULTS_NAME}/sysinfo.log
./phoronix-test-suite result-file-to-json $${TEST_RESULTS_NAME} > $${phoronixRSFolder}/$${TEST_RESULTS_NAME}/$${TEST_RESULTS_NAME}.json

cat $${phoronixRSFolder}/$${TEST_RESULTS_NAME}/$${TEST_RESULTS_NAME}.json | jq -c --arg name $${TEST_RESULTS_NAME} --arg instancetype $${instanceTypeOnly} --arg cpuplatform $${cpuPlatform} --arg cpucore $${cpu_core} --arg cpuspeed $${cpu_speed} --arg memsize $${mem_size} --arg band $${band} '.results[] | {band:$band, name:$name, instance_type:$instancetype, cpu_platform:$cpuplatform, cpu_count:$cpucore, cpu_speed:$cpuspeed, mem_size:$memsize, test: .test, argument: .arguments, unit: .units, value: .results[].value}' | sed "s/pts\///g" | sed "s/\///g" >> $${phoronixRSFolder}/$${TEST_RESULTS_NAME}/new.json


# Install and initial Azure CLI
echo start install and initial Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login --service-principal --username ${appid} --password ${password} --tenant ${tenantid}


echo start upload
az storage blob upload  --account-name ${storage_account} --container-name ${container} --file $${phoronixRSFolder}/$${TEST_RESULTS_NAME}/new.json --name $${TEST_RESULTS_NAME}.json


echo End: user-data

echo Shutting down host

shutdown -h now
