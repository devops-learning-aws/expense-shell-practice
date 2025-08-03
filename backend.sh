#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter yopur DB password:"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ] 
    then 
        echo -e  "$2 $R failed $N"
        exit 1
    else
        echo -e "$2 $G success $N"
    fi        
}

if [ $USERID -ne 0 ]
then 
    echo -e "$R Please run with super user access $N"
    exit 1
else
    echo -e "$G you are super user $N"

fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling node 18"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling node20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing node "

id expense &>>$LOGFILE
if [ $? -ne 0 ] 
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "add user expsense"
else
    echo " $Y already added skipping $N"
 fi   
   
mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading the zip file of source code"

cd /app
rm -rf /app/* 

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "extractng the backend code"

npm install &>>$LOGFILE
VALIDATE $? "npm installng"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "coping the backend service file"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reload the server"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Staring the backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enable backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"


#mysql -h db.daws78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
#VALIDATE $? "Schema loading"

mysql -h 172.31.80.46 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restart backen"