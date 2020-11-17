echo "installing mssql-tools"
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-${DISTRO}-${CODENAME}-prod ${CODENAME} main" > /etc/apt/sources.list.d/microsoft.list
apt-get update
apt-get -y install unixodbc-dev
ACCEPT_EULA=Y apt-get -y install msodbcsql17
ACCEPT_EULA=Y apt-get -y install mssql-tools

echo "installing sqlpackage"
apt-get -y install wget
apt-get -y install libunwind8
apt-get -y install libicu60
apt-get -y install unzip
wget -O sqlpackage.zip "https://aka.ms/sqlpackage-linux"
mkdir /opt/sqlpackage
unzip sqlpackage.zip -d /opt/sqlpackage 
rm sqlpackage.zip
chmod a+x /opt/sqlpackage/sqlpackage
