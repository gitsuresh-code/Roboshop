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

dnf list installed nodejs &>>$log
validate $? "Nodejs Available Check"

dnf module disable nodejs -y &>>$log
validate $? "Nodejs disabling"

dnf module enable nodejs:20 -y &>>$log
validate $? "Nodejs enabling"

dnf install nodejs -y &>>$log
validate $? "Nodejs Installing"

id roboshop &>>$log
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate "Adding Application user"
else
    echo "User is already exist" | tee -a $log
fi

mkdir -p /app 
validate $? "Adding App Directory"

rm -rf /app/*
validate $? "Deleting old files"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$log
validate $? "Downloading Cart Files"

cd /app
validate $? "Switching to App Directory"

unzip /tmp/cart.zip &>>$log
validate $? "Unzipping to App Directory"


npm install &>>$log
validate $? "Installing Dependency Files"

cp /root/Roboshop/cart.service /etc/systemd/system/cart.service &>>$log
validate $? "Copying the Cart service file"

systemctl daemon-reload &>>$log
validate $? "Reloading Daemon File"

systemctl enable cart &>>$log
validate $? "Cart Enabling"

systemctl start cart &>>$log
validate $? "Cart starting"



