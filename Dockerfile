# Stage 1 — build Flutter web
FROM ubuntu:22.04 AS builder

# Avoid tar ownership errors when Flutter extracts artifacts
ENV TAR_OPTIONS="--no-same-owner"

# Install basic dependencies required by Flutter
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils build-essential libglu1-mesa-dev python3 tar \
  && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME
ENV PATH="$FLUTTER_HOME/bin:$PATH"

WORKDIR /app

# Copy pubspec files first for layer caching
COPY pubspec.* ./

# --- IMPORTANT: copy any local path packages referenced in pubspec.yaml ---
# e.g., dynamic_form_kit is a local folder at project root. If it's in a subfolder,
# change the source path accordingly.
COPY dynamic_form_kit ./dynamic_form_kit

# Now resolve Dart/Flutter dependencies (path packages are available now)
RUN flutter pub get --offline || flutter pub get

# Copy the rest of the repository
COPY . .

# Build the web release
RUN flutter build web --release --web-renderer html

# Stage 2 — nginx to serve the static files
FROM nginx:stable-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
