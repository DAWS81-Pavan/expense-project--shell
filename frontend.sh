#!/bin/bash
LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

userid=$(id -u)
R="\e[31m" #RED
G="\e[32m" #GREEN
N="\e[0m"  #NARMAL
Y="\e[33m" #YELLOW

CHECK_ROOT(){

    if [ $userid -ne 0 ]
    then
        echo "Please run this script with root priveleges"| tee -a $LOG_FILE
        exit 1
    fi

}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is...$G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

echo "Script started executing at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "install nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "remove the existing code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading backend application code"

cd /usr/share/nginx/html &>>$LOG_FILE
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extracting backend application code"

cp /home/ec2-user/expense_project-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restart nginx"