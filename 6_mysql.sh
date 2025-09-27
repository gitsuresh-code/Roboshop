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

dnf list installed mysql-server &>>$log
validate $? " Mysql available check"

dnf install mysql-server -y &>>$log
validate $? "installing Mysql"

systemctl enable mysqld &>>$log
validate $? "Enabling Mysql"

systemctl start mysqld &>>$log
validate $? "Starting Mysql"

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "Setting password"