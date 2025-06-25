
read -p "Which world to clean? Enter Port or type all: " action

case $action in

  all)
	docker rm -f $(sudo docker ps -a -q)
	rm -rf /worlds/*
	;;
  *)
	if [ -d "/worlds/minecraft_$action" ]; then
	  rm -rf /worlds/minecraft_$action
	  docker rm -f mc_$action
	  echo "world deleted."
	  exit 0
	else
	  echo "World Doesnt Exist"
	  exit 2
	fi
  	;;
esac
