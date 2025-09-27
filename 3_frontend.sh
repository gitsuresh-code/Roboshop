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


dnf module disable nginx -y &>>$log
validate $? "Disabling default NGINX"

dnf module enable nginx:1.24 -y &>>$log
validate $? "Enabling NGINX 20 version"

dnf install nginx -y &>>$log
validate $? "Installing NGINX"

systemctl enable nginx &>>$log
validate $? "Enabling NGINX"

systemctl start nginx &>>$log
validate $? "Starting NGINX"

cd /usr/share/nginx/html/ &>>$log
validate $? "Switching to NGINX HTML Directory"

rm -rf * &>>$log
validate $? "Delete default NGINX files"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$log
validate $? "Downloading front files to temp"   

unzip /tmp/frontend.zip &>>$log
validate $? "Unzipping files to NGINX directory"

cp /root/Roboshop/nginx.conf /etc/nginx/nginx.conf &>>$log
validate $? "Updating nginx config file"

systemctl restart nginx &>>$log
validate $? "Restarting nginx server"

end_time=$(date +%s)
total_time=$(($end_time-$start_time))

echo -e "Script executed in $Y $total_time $N"
