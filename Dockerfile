# Stage 1 — build Flutter web
FROM ubuntu:22.04 AS builder

# Avoid tar ownership errors when Flutter extracts artifacts
ENV TAR_OPTIONS="--no-same-owner"

# Install packages required by Flutter
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils build-essential libglu1-mesa-dev python3 tar sudo \
  && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
# Clone stable Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Create a non-root user and give ownership of flutter and /app
RUN useradd -m -u 1000 flutteruser && \
    mkdir -p /app && \
    chown -R flutteruser:flutteruser $FLUTTER_HOME && \
    chown -R flutteruser:flutteruser /app

WORKDIR /app

# Copy pubspec files first for layer caching
COPY pubspec.* ./

# Copy any local path packages referenced in pubspec.yaml so pub get can resolve them
# Adjust this COPY line if your local package path differs
COPY dynamic_form_kit ./dynamic_form_kit

# Switch to non-root user for flutter commands
USER flutteruser

# Accept flutter licenses & pre-cache artifacts (optional, but helps)
RUN flutter --version
# Resolve dependencies (path packages are available now)
RUN flutter pub get --offline || flutter pub get

# Copy rest of repo (still as non-root)
COPY --chown=flutteruser:flutteruser . .

# Build the web release (no --web-renderer flag)
RUN flutter build web --release

# Stage 2 — nginx to serve the static files
FROM nginx:stable-alpine AS runtime
RUN rm -rf /usr/share/nginx/html/*
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
