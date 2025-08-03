#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "please enter you DB Password"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ] 
    then 
       echo -e "$2 $R falled $N"
       exit 1
    else
       echo -e "$2 $G success $N"
    fi      
}

if [ $USERID -ne 0 ] 
then
     echo "please run wiith super user access"
     exit 1
else
     echo "you are a super user"
fi

dnf install mysql -y  &>>$LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "enabling mysql"

systemctl start mysqld $>>$LOGFILE
VALIDATE $? "starting mysql"

mysql -h db.daws78s.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ] 
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "setting up root password"
else
    echo "alreeady setupped root password skippng up"
fi