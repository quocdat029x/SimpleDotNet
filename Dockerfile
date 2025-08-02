FROM mcr.microsoft.com/dotnet/runtime-deps:9.0
WORKDIR /app
COPY ./publish/HelloWorldAppDocker .
EXPOSE 8080
ENTRYPOINT ["./HelloWorldApp"]
