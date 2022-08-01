# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
RUN mkdir /root/.ssh && chmod 0700 /root/.ssh
#RUN apk add --no-cache openssh-client

#RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
#RUN chmod 400 ~/.ssh/id_rsa
#RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN --mount=type=ssh ssh -q -T git@github.com 2>&1 | tee /hello
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

# Start server.
EXPOSE 8080
CMD ["dart","/app/bin/server.dill"]
