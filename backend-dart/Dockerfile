# Use an official Dart runtime as a parent image
FROM dart:stable

# Set the working directory inside the container
WORKDIR /app

# Copy the pubspec and pubspec.lock files to the working directory
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy the rest of the application code to the working directory
COPY . .

# Expose the port your server will run on
EXPOSE 8080

# Define environment variables for host and port
ENV HOST=0.0.0.0
ENV PORT=8080

# Run the server when the container launches
CMD ["dart", "bin/server.dart"]