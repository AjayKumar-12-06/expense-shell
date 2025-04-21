#!/bin/bash
#1 - create the sudo user
#2 - colors
#3-logs with time 

USERID=$(id -u)

#colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#creating log folder in below structure
# /var/log/expense/script_name-time

LOGS_FOLDER="var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d " " -f1)
TIMESTAMP=$(date +-%y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP".log



mkdir -p $LOGS_FOLDER


check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e " $R You must have the sudo access to execute this $N"
        exit 1
    fi
}

check_root

validate(){
    if [ $1 -ne 0 ]; then
        echo -e " $R $2 Installing ...Failure $N"
        exit 1
    else
        echo -e " $G $2 Installing success"
    fi
}

echo "Script executed at : $(date)" | tee -a $LOG_FILE

dnf install mysql-server -y &>>$LOG_FILE
validate $? "installing mysql"

systemctl enable mysqld &>>$LOG_FILE
validate $? "enable mysql"

systemctl start mysqld &>>$LOG_FILE
validate $? "started mysql"

mysql -h myfooddy.fun -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "Mysql root password is not setup, setting now"
    mysql_secure_installation --set-root-pass ExpenseApp@1
    validate $? "setting root password"
fi



