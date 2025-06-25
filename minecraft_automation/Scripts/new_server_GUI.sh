# set min and max port

yourIP=$(curl https://ipinfo.io/ip > /dev/null)
echo $yourIP
min=25000
max=25006

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

#ask for version

echo "Choose requested version:"
echo "for example:"
echo "1.21.4"
read version

case $version in
	"1.21.4")
	  version="1.21.4"
	  ;;

	"1.21.6")
	  version="1.21.6"
	  ;;

	*)
	echo "Invalid Answer, Version not available"
	exit 2
	;;
esac

# port chosen
echo your ID is: $port
mkdir  /worlds/minecraft_$port

# create and start the docker container
docker run -d --name=mc_$port -p $port:25565 -v /worlds/minecraft_$port:/data mc/minecraft_v$version /start

# give the user op permissions
echo "Let me know your Minecraft Username so i can give you OP permissions:"
read username
python3 ./give_op_whitelist.py "$port" "$username"

sleep 5
while [ ! -f "/worlds/minecraft_$port/server.properties" ]; do
	echo "Loading.."
	sleep 1
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
