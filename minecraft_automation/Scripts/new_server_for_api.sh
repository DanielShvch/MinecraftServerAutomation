#!/bin/bash
# set min and max port
username=$1
versionUser=$2
versionAvailable=("1.21.4" "1.21.6")
min=25000
max=25006

if [[ -z "$1" || -z "$2" ]]; then
	echo "Invalid parameter - Correct usage is noted in documentation"
	exit 1
fi

# check if the vesion is available.
pass=false
for version in "${versionAvailable[@]}"; do
        if [[ "$version" == "$2" ]]; then
                pass=true
                break
        fi
done

if [[ "$pass" == "false" ]]; then
        echo "Error - Version not found"
        exit 1
fi

#check if it exist and set max servers
for ((port=$min; port<=$max; port++)); do
    if [ ! -d "/worlds/minecraft_$port" ]; then
        break
    fi
done


# exit if all ports are taken
if [ "$port" -gt "$max" ]; then
    echo "We are busy ATM, all servers are taken."
    exit 1
fi

# port chosen
echo your ID is: $port
mkdir  /worlds/minecraft_$port

# create and start the docker container
#echo "version is $2"
docker run -d --name=mc_$port -p $port:25565 -v /worlds/minecraft_$port:/data mc/minecraft_v$2 /start > /dev/null

# give the user op permissions and whitelist
python3 /minecraft_automation/Scripts/give_op_whitelist.py "$port" "$username" > /dev/null

while [ ! -f "/worlds/minecraft_$port/server.properties" ]; do
	#echo "Loading.."
	sleep 2
	((++timeout))
	if [ "$timeout" = 10 ]; then
	  echo "Error - Timeout - Prossess took too long"
          rm -rf /worlds/minecraft_$port
          docker rm -f mc_$port
	  exit 1
	fi
done

sed -i 's/white-list=false/white-list=true/g' /worlds/minecraft_$port/server.properties

docker restart mc_$port

#conclude
if [ $? -eq 0 ]; then
	echo "200 - OK - Your server is Up and running! - You can add your minecraft server with IP: 129.159.153.50:$port"
	exit 0
else
	echo "Oh no, something failed, Please try again."
	rm -rf /worlds/minecraft_$port
	docker rm -f mc_$port
	exit 1
fi
