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


if [ $user -ne 0 ]; then
    
    echo -e "$R Please take root permission $N" | tee -a $log
    exit 1
             
fi

validate()
{
    if [ $? -ne 0 ]; then
        echo -e "$2 $R is FAILURE $N"
        else
        echo -e "$2 $G is SUCCESS $N"
    fi 
}

dnf list installed redis &>>$log
validate $? "Redis Available"

dnf module disable redis -y &>>$log
validate $? "disabling default version"

dnf module enable redis:7 -y &>>$log
validate $? "enabling version"

dnf install redis -y &>>$log
validate $? "Redis Available"

# sed -i -e 's/127.0.0.1/0.0.0.0 -e /protected-mode/c protected-mode no'/etc/redis/redis.conf &>>$log
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf &>>$log
validate $? "Redis Enabling Public Access"

sed -i '/protected-mode/c protected-mode no' /etc/redis/redis.conf &>>$log
validate $? "Protected Mode off"

systemctl enable redis &>>$log
validate $? "Redis Enabling"

systemctl start redis &>>$log
validate $? "start service"



        
  






