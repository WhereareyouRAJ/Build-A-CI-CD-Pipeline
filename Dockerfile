# Use official Node.js LTS image
FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package files first (to leverage Docker cache)
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy all other app files
COPY . .

# App listens on port 5000
EXPOSE 5000

# Start the app
CMD ["node", "index.js"]
