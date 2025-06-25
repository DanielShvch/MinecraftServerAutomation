#!/bin/bash
# set min and max port
username=$1
versionUser=$2
versionAvailable=("1.21.4" "1.21.6")
min=25000
max=25006
yourIP=<yourIP>

if [[ -z "$1" || -z "$2" ]]; then
	echo "Missing Parameters parameters."
	echo "Correct usage is ./new_server_nogui.sh <Minecraft_Username> <wanted version>"
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
echo "version is $2"
docker run -d --name=mc_$port -p $port:25565 -v /worlds/minecraft_$port:/data mc/minecraft_v$2 /start
if [[ "$?" != "0" ]]; then
	echo "unkown error"
	exit 4
fi

#give the user op permissions, Yes i used ChatGPT
#echo "Let me know your Minecraft Username so i can give you OP permissions:"
python3 ./give_op_whitelist.py "$port" "$username"

timeout=0
while [ ! -f "/worlds/minecraft_$port/server.properties" ]; do
	echo "Loading.."
	sleep 2
	((++timeout))
	if [ "$timeout" = 10 ]; then
	  echo "Error - Timeout"
	  exit 1
	fi
done

sed -i 's/white-list=false/white-list=true/g' /worlds/minecraft_$port/server.properties

docker restart mc_$port

#conclude
if [ $? -eq 0 ]; then
	echo "Your server is Up and running!"
	echo "You can add your minecraft server with IP: $yourIP:$port"
	echo "$username , Have Fun!"
	echo " "
	echo "If you have any issues with this server, Feel free to contact us!"
	echo "Make sure you add your servers IP to your request."
	exit 0
else
	echo "Oh no, something failed, Please try again."
	rm -rf /worlds/minecraft_$port
	docker rm -f mc_$port
	exit 1
fi
