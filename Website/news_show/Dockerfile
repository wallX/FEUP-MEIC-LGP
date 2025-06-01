FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

# Install dependencies with platform-specific flags
RUN npm install --platform=linux --arch=x64

COPY . .

EXPOSE 5173

# Use host 0.0.0.0 to allow external connections
ENV HOST=0.0.0.0

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
