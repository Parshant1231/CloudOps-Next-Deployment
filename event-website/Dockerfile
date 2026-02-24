# Stage 1: Build the application
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Run the application
FROM node:20-slim
WORKDIR /app
# Only copy the built 'dist' folder from the builder stage
COPY --from=builder /app/dist ./dist
# If you have a public folder for your website assets, copy it too
COPY --from=builder /app/public ./public

EXPOSE 3000
CMD ["node", "dist/index.js"]