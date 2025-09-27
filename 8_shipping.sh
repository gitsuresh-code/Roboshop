#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[32m"
N="\e[0m"
user=$(id -u)
file="/var/log/roboshoplog/"
name=$(echo $0 | cut -d "." -f1)
log=$file/$name.log

echo -e "Script $G started executing $N now: $date"
start_time=$(date +%s)
mkdir -p $file



if [ $user -ne 0 ]; then
        echo -e "$R Please take root permission $N" | tee -a $log
        exit 1
      
fi

validate()
{
    if [ $? -ne 0 ]; then
        echo -e "$2 $R is FAILURE $N" | tee -a $log 
        else
        echo -e "$2 $G is SUCCESS $N" | tee -a $log
    fi 
}


dnf install maven -y &>>$log
validate $? "Instaling Maven"

id roboshop &>>$log
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Adding Application user"
else
    echo "User already exist"

fi

mkdir -p /app  
validate $? "Creating App Directory"

rm -rf /app/*
validate $? "Deleting App Files"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$log
validate $? "Downloading App Files"

cd /app 
validate $? "Switching to App Directory"

unzip /tmp/shipping.zip &>>$log
validate $? "Unzipping Files"


mvn clean package &>>$log
validate $? "Generating Build File"

mv target/shipping-1.0.jar shipping.jar 
validate $? "Moving build file"

cp /root/Roboshop/shipping.service /etc/systemd/system/shipping.service
validate $? "Copying the shipping service file to systemd"

systemctl daemon-reload
validate $? "Reloading Daemon"

systemctl enable shipping &>>$log
validate $? "Enabling shipping service"

systemctl start shipping
validate $? "Starting shipping service"


dnf install mysql -y &>>$log
validate $? "Installing mysql client"


mysql -h mysql.sureshdevops.fun -uroot -pRoboShop@1 < /app/db/schema.sql &>>$log
validate $? "Loading Schema"


mysql -h mysql.sureshdevops.fun -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$log
validate $? "Loading App User data"

mysql -h mysql.sureshdevops.fun -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$log
validate $? "Loading Master data"


systemctl restart shipping &>>$log
validate $? "restarting shipping"





