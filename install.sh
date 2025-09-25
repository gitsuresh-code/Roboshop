#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-script" #/var/log/shell-script/
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 ) #20_logs
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/20_logs.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # Programm will end here 
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 Installation  ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 Installation  ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

for package in $@
{
if [ $? -ne 0 ]; then
    dnf install $package -y &>>$LOG_FILE
    VALIDATE $? $package
else
    echo -e "$package already exist ... $Y SKIPPING $N" | tee -a $LOG_FILE
fi

}



