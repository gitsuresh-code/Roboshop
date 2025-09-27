#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[32m"
N="\e[0m"
user=$(id -u)
file="/var/log/roboshoplog/"
name=$(echo $0 | cut -d "." -f1)
log=$file/$name.log

mkdir -p $file

start_time=$(date +%s)


if [ $user -ne 0 ]; then
    {
        echo -e "$R Please take root permission $N" | tee -a $log
        exit 1
    }         
fi

validate()
    {
         if [ $? -ne 0 ]; then
            echo -e "$2 $R is FAILURE $N"
            else
            echo -e "$2 $G is SUCCESS $N"
        fi 
    }

dnf list installed mongodb-org &>>$log
validate $? "MogoDB Available"

cp /root/Roboshop/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>>$log
validate $? "MongoDB installation"

systemctl enable mongod &>>$log
validate $? "MongoDB Enabling"

systemctl start mongod &>>$log
validate $? "MongoDB start"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$log
validate $? "Updating Config file"

systemctl restart mongod &>>$log
validate $? "restarting service"

end_time=$(date +%s)
total_time=$(($end_time-$start_time))

echo -e "$G Script executed$N  in $total_time"
        
  






