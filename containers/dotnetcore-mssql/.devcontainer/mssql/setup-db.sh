sleep 60s

dacpac="false"

for f in *
do
    if [ $f == *".dacpac" ]
    then
        dacpac="true"
        echo "found dacpac $f"
    fi
done
if [ $dacpac = "true" ] 
then
    apt-get -y install wget
    apt-get -y install libunwind8
    apt-get -y install libicu60
    apt-get -y install unzip
    wget -O sqlpackage.zip "https://go.microsoft.com/fwlink?linkid=2143497"
    mkdir sqlpackage
    unzip sqlpackage.zip -d ./sqlpackage 
    sleep 60s
    chmod a+x ./sqlpackage/sqlpackage
    for f in *
    do
        if [ $f == *".dacpac" ]
        then
            dbname=$(basename $f ".dacpac")
            ./sqlpackage/sqlpackage /Action:Publish /SourceFile:$f /TargetServerName:localhost /TargetDatabaseName:$dbname /TargetUser:sa /TargetPassword:$SA_PASSWORD
            echo "deploying dacpac $f"
        fi
    done
else
    echo "creating blank db"
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i setup.sql
fi