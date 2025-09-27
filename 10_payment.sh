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

dnf install python3 gcc python3-devel -y
validate $? "Python3 installation"


id roboshop &>>$log
if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "Adding Application user"
    else
        echo "user already exist..$Y skipping $N"
fi


mkdir -p /app 
validate $? "Creating App Directory"

rm -rf /app/*
validate $? "Deleting Old App Directory files"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log
validate $? "Downloading the files"

cd /app 
validate $? "Switching to the App directory"


unzip /tmp/payment.zip &>>$log
validate $? "Unzipping the files to app"


pip3 install -r requirements.txt &>>$log
validate $? "Download the dependencies"

cp /root/Roboshop/payment.service /etc/systemd/system/payment.service
validate $? "Copying the payment service to systemd"

systemctl daemon-reload
validate $? "Daemon Reloading"


systemctl enable payment 
validate $? "Enabling Payment Service"

systemctl start payment
validate $? "Starting Payment Service"


