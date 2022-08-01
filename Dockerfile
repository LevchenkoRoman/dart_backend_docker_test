# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
RUN mkdir /root/.ssh && chmod 0700 /root/.ssh
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile kernel bin/server.dart -o bin/server.dill

# Build serving image
FROM dart:stable
#COPY --from=build /runtime/ /
COPY --from=build /app/bin/server.dill /app/bin/server.dill

# Start server.
EXPOSE 8080
CMD ["dart","/app/bin/server.dill"]
