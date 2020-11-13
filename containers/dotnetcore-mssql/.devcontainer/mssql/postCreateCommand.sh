dacpac="false"
sqlfiles="false"
SApassword=$1
dacpath=$2
sqlpath=$3

echo "SELECT * FROM SYS.DATABASES" | dd of=testsqlconnection.sql
for i in {1..60};
do
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SApassword -d master -i testsqlconnection.sql
    if [ $? -eq 0 ]
    then
        echo "sql server ready"
        break
    else
        echo "not ready yet..."
        sleep 1
    fi
done
rm testsqlconnection.sql

for f in $dacpath/*
do
    if [ $f == $dacpath/*".dacpac" ]
    then
        dacpac="true"
        echo "found dacpac $f"
    fi
done

for f in $sqlpath/*
do
    if [ $f == $sqlpath/*".sql" ]
    then
        sqlfiles="true"
        echo "found sql file $f"
    fi
done

if [ $sqlfiles == "true" ]
then
    echo "installing mssql-tools"
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
    apt-get update
    apt-get -y install unixodbc-dev
    ACCEPT_EULA=Y apt-get -y install msodbcsql17
    ACCEPT_EULA=Y apt-get -y install mssql-tools
    for f in $sqlpath/*
    do
        if [ $f == $sqlpath/*".sql" ]
        then
            echo "executing $f"
            /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SApassword -d master -i $f
        fi
    done
fi

if [ $dacpac == "true" ] 
then
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
    for f in $dacpath/*
    do
        if [ $f == $dacpath/*".dacpac" ]
        then
            dbname=$(basename $f ".dacpac")
            echo "deploying dacpac $f"
            /opt/sqlpackage/sqlpackage /Action:Publish /SourceFile:$f /TargetServerName:localhost /TargetDatabaseName:$dbname /TargetUser:sa /TargetPassword:$SApassword
        fi
    done
fi