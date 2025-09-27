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
    {
        echo -e "$R Please take root permission $N" | tee -a $log
        exit 1
    }         
fi

validate()
{
    if [ $? -ne 0 ]; then
        echo -e "$2 $R is FAILURE $N" | tee -a $log 
        else
        echo -e "$2 $G is SUCCESS $N" | tee -a $log
    fi 
}

dnf module disable nodejs -y &>>$log
validate $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$log
validate $? "Enabling nodejs 20 version"

dnf install nodejs -y &>>$log
validate $? "Installing nodejs"

id roboshop &>>$log
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log
validate $? "Adding Application user"
else
    echo "User is already exist"
fi


mkdir -p /app &>>$log
validate $? "Creating App directory"

rm -rf /app/*
validate $? "Deleting old files"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log
validate $? "Dowloading backend files"

cd /app
validate $? "Switching to app directory"

unzip /tmp/catalogue.zip &>>$log
validate $? "Unzipping the app files"


npm install &>>$log
validate $? "installing dependency packages"

cp /root/Roboshop/catalogue.service /etc/systemd/system/catalogue.service
validate $? "Copying catalogue service file"

systemctl daemon-reload &>>$log
validate $? "Reloading Catalogue service"

systemctl enable catalogue &>>$log
validate $? "Enabling Catalogue service"


systemctl start catalogue &>>$log
validate $? "Starting Catalogue service"

cp /root/Roboshop/mongo.repo /etc/yum.repos.d/mongo.repo


dnf install mongodb-mongosh -y &>>$log 
validate $? "Installing mongo client"


mongosh --host mongo.sureshdevops.fun </app/db/master-data.js
validate $? "Loading DB Schema"

end_time=$(date +%s)
total_time=$(($end_time-$start_time))

echo -e "$G Script executed$N  in $total_time"
