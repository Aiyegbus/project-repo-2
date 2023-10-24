# Use an official lightweight Node.js runtime as the base image
FROM node:14-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy your application files to the container
COPY index.html .
COPY script.js .
COPY styles.css .

# Expose a port if your app requires it
# EXPOSE 80

# Define the command to run your application
CMD [ "npx", "http-server", "-p", "80" ]
