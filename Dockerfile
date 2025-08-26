# ============================
# 1. Build Stage
# ============================
FROM node:20.12.2-alpine AS builder

WORKDIR /usr/src/app
ENV PATH /usr/src/app/node_modules/.bin:$PATH

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build


# ============================
# 2. Nginx Stage
# ============================
FROM nginx:1.25-alpine

RUN rm -rf /etc/nginx/conf.d/*

COPY conf/default.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /usr/src/app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
