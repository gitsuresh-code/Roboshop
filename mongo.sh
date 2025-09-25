#!/bin/bash

R="/e[31m"
G="/e[32m"
Y="/e[32m"
N="/e[0m"
user=$(id -u)
file="/var/log/roboshoplog/"
name=$(echo $0 | cut -d "." -f1)
log=$file/$name.log

mkdir -p $file

cp ./mongo.repo /etc/yum.repos.d/ 


if [ $user -ne 0 ];then
    {
        echo -e "$R Please take root permission $N" | tee -a $log
        exit 1
    }         
fi

validate()
{
    if [ $? -ne 0 ];then
        echo -e "$2 $R is FAILURE $N"
        else
        echo "$2 $R is SUCCESS $N"
    fi 
}

dnf list installed &>>$log
validate $? "MogoDB Available Check"

dnf install mongodb-org -y
validate $? "MongoDB installation"

systemctl enable mongod
validate $? "MongoDB Enabling"

systemctl start mongod
validate $? "MongoDB start"

sed -i "s/127.0.0.1/0.0.0.0" /etc/mongod.conf
validate $? "Updating conf file"

systemctl restart mongod
validate $? "restarting service"


        
  






