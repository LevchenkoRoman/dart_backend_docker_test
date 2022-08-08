# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
RUN mkdir /root/.ssh && chmod 0700 /root/.ssh
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
WORKDIR /app
COPY pubspec.* ./
RUN --mount=type=ssh dart pub get

# Copy app source code (except anything in .dockerignore)compile app.
COPY . .
RUN dart compile kernel bin/server.dart -o bin/server.dill

# Build serving image
FROM dart:stable
#COPY --from=build /runtime/ /
COPY --from=build /app/bin/server.dill /app/bin/server.dill
WORKDIR /app/bin
# Start server.
#EXPOSE 8080 - for inner container access, not needed is using -p (publish ports)
CMD ["dart","run","server.dill"]
