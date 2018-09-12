
FROM debian:stretch
ENV CAKE_VERSION 0.30.0
ENV CAKE_SETTINGS_SKIPVERIFICATION true
ADD cakeprimer cakeprimer
ADD cake /usr/bin/cake


# Install .NET Core and Mono
RUN apt-get update \
    && apt-get install -y apt-transport-https curl dirmngr unzip \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb https://download.mono-project.com/repo/debian stable-stretch main" | tee /etc/apt/sources.list.d/mono-official-stable.list \
    && curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg \
    && mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ \
    && curl -s https://packages.microsoft.com/config/debian/9/prod.list | tee /etc/apt/sources.list.d/microsoft-prod.list \
    && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg \
    && chown root:root /etc/apt/sources.list.d/microsoft-prod.list \
    && apt-get update \
    && apt-get install -y mono-complete dotnet-sdk-2.1 \
    && apt-get clean \
    && mkdir -p /opt/nuget \
    && curl -Lsfo /opt/nuget/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

ENV PATH "$PATH:/opt/nuget"

# Prime dotnet & Cake
RUN mkdir dotnettest \
    && cd dotnettest \
    && dotnet new console -lang C# \
    && dotnet restore \
    && dotnet build \
    && dotnet run \
    && cd .. \
    && rm -r dotnettest \
    && cd cakeprimer \
    && dotnet restore Cake.sln \
    --source "https://www.myget.org/F/xunit/api/v3/index.json" \
    --source "https://api.nuget.org/v3/index.json" \
     /property:UseTargetingPack=true \
    && cd .. \
    && rm -rf cakeprimer

# Install Cake & Test Cake & Display info installed components
RUN mkdir -p /opt/Cake/Cake \
    && curl -Lsfo Cake.zip "https://www.nuget.org/api/v2/package/Cake/$CAKE_VERSION" \
    && unzip -q Cake.zip -d "/opt/Cake/Cake" \
    && rm -f Cake.zip \
    && chmod 755 /usr/bin/cake \
    && sync \
    && mkdir caketest \
    && cd caketest \
    && cake --version \
    && cd .. \
    && rm -rf caketest \
    && mono --version \
    && dotnet --info \