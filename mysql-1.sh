#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/expenses"
script_name=$(echo $0 | cut -d " " -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$script_name-$TIMESTAMP".log

mkdir -p $LOGS_FOLDER

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e " $R You must have the root access to excute this $N"
        exit 1
    fi
}

check_root

validate(){
    if [ $1 -ne 0 ]; then
        echo -e " $2 $R failure $N"
        exit 1
    else
        echo -e " $2 $G success $N"
    fi
}

echo "code execution at $(date)"

dnf install mysql-server -y &>>$LOG_FILE
validate $? "installing mysql server"

systemctl enable mysqld &>>$LOG_FILE
validate $? "enable mysql"

systemctl start mysqld &>>$LOG_FILE
validate $? "started mysql"

mysql -h myfooddy.fun -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    echo "setting root password if not" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
    validate $? "setting root password"
else
    echo "mysql root password already set $Y SKIPPING $N"
fi