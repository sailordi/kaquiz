# Variables
IMAGE_NAME = my_friend_tracker_api
CONTAINER_NAME = friend_tracker_api_container
HOST = 0.0.0.0
PORT = 8080

# Default target
all: build run

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the Docker container
run: stop
	docker run -d -p $(PORT):$(PORT) --name $(CONTAINER_NAME) -e HOST=$(HOST) -e PORT=$(PORT) $(IMAGE_NAME)

# Stop and remove the running container
stop:
	@if docker ps -a | grep -q $(CONTAINER_NAME); then \
		docker stop $(CONTAINER_NAME); \
		docker rm $(CONTAINER_NAME); \
	fi

# Remove the Docker image
clean: stop
	@if docker images -q $(IMAGE_NAME); then \
		docker rmi $(IMAGE_NAME); \
	fi

# Show logs from the container
logs:
	docker logs -f $(CONTAINER_NAME)