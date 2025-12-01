# Stage 1 — build Flutter web
FROM ubuntu:22.04 AS builder

# Make sure tar honors no-same-owner (prevents "Cannot change ownership" errors)
ENV TAR_OPTIONS="--no-same-owner"

# Install basic dependencies required by Flutter
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils build-essential libglu1-mesa-dev python3 tar \
  && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
# Clone flutter stable
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME
ENV PATH="$FLUTTER_HOME/bin:$PATH"

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get --offline || flutter pub get
COPY . .
RUN flutter build web --release --web-renderer html

# Stage 2 — nginx to serve the static files
FROM nginx:stable-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

