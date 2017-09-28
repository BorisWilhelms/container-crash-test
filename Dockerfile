FROM microsoft/dotnet:2.0.0-sdk as build-env

WORKDIR /app
COPY ./container-crash-test /app/container-crash-test
RUN cd container-crash-test && dotnet restore
RUN cd container-crash-test && dotnet publish -c Release -o /app/out

FROM microsoft/aspnetcore:2.0
WORKDIR /app
COPY --from=build-env /app/out .

# Install SSH
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server \
    && echo "root:Docker!" | chpasswd

EXPOSE 2222 3000

# Copy the sshd_config file to its new location
COPY sshd_config /etc/ssh/

# Start the SSH service
RUN service ssh start

ENV ASPNETCORE_URLS "http://*:3000"
CMD ["dotnet", "container-crash-test.dll"]


