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
    echo "User already exist"

fi


mkdir -p /app &>>$log
validate $? "Creating App directory"

rm -rf /app/*
validate $? "Creating App directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$log
validate $? "Dowloading backend files"

cd /app &>>$log
validate $? "Switching to app directory"

unzip /tmp/user.zip &>>$log
validate $? "Unzipping the app files"


npm install &>>$log
validate $? "installing dependency packages"

cp /root/Roboshop/user.service /etc/systemd/system/user.service
validate $? "Copying the user service file to systemd"

systemctl daemon-reload 
validate $? "Reloading user service"

systemctl enable user &>>$log
validate $? "Enabling user service"


systemctl start user &>>$log
validate $? "Starting user service"


end_time=$(date +%s)
total_time=$(($end_time-$start_time))

echo -e "$G Script executed$N  in $total_time"
