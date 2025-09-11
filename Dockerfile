# ============================
# 1. Build Stage (React build)
# ============================
FROM node:20.12.2-alpine AS builder

WORKDIR /usr/src/app
ENV PATH=/usr/src/app/node_modules/.bin:$PATH

# Copy dependency files first (better cache)
COPY package*.json ./

# Install dependencies (use npm ci if lockfile exists)
RUN npm install --global npm@10 \
    && if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi

# Copy source code and build
COPY . .
RUN npm run build

# ============================
# 2. Nginx Stage (Production)
# ============================
FROM nginx:1.25-alpine

# Remove default config
RUN rm -rf /etc/nginx/conf.d/*

# Copy custom nginx config
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copy React build output to nginx html directory
COPY --from=builder /usr/src/app/build /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

