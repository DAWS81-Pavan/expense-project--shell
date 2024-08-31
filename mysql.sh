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

dnf list installed mysql-server &>>$LOG_FILE
if [ $? -ne 0 ]
 then
    echo "mysql is not installed, going to install it.." | tee -a $LOG_FILE
    dnf install mysql-server -y &>>$LOG_FILE
    VALIDATE $? "install mysql-server"
    # if [ $? -ne 0 ]
    # then
    #     echo -e "mysql installation is $R not success $N ...check it" | tee -a $LOG_FILE
    #     exit 1
    # else
    #     echo -e "mysql installation is $G success $N" | tee -a $LOG_FILE
    # fi
 else
    echo -e "mysql is already $Y installed, nothing to do..$N"
fi

systemctl is-enabled mysqld &>>$LOG_FILE
if [ $? -ne 0 ]
 then
    echo "mysql is disabled , going to enable it.." | tee -a $LOG_FILE
    systemctl enable mysqld &>>$LOG_FILE
    VALIDATE $? "enable mysql"
    # if [ $? -ne 0 ]
    # then
    #     echo -e "mysql enable is $R not success$N...check it" | tee -a $LOG_FILE
    #     exit 1
    # else
    #     echo -e "mysql enabled $G successfully$N" | tee -a $LOG_FILE
    # fi
 else
    echo -e "mysql service is $G enabled already nothing to do.. $N" | tee -a $LOG_FILE
fi

systemctl status mysqld &>>$LOG_FILE
if [ $? -ne 0 ]
 then
    echo "mysql service is not running , going to start the service.." | tee -a $LOG_FILE
    systemctl start mysqld &>>$LOG_FILE
    VALIDATE $? "enable mysql"
    # if [ $? -ne 0 ]
    # then
    #     echo -e "mysql service is $R not success...check it $N" | tee -a $LOG_FILE
    #     exit 1
    # else
    #     echo -e "mysql service started $G successfully $N" | tee -a $LOG_FILE
    # fi
 else
    echo -e "mysql service is $G running already nothing to do..$N" | tee -a $LOG_FILE
fi

sudo mysql -h mysql.dev.pdevops.online -u root -pExpenseApp@1 -e "show databases;" &>>$LOG_FILE
if [ $? -ne 0 ]
then 
    echo "mysql root password is not setup, setting up now" | tee -a $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
else
    echo -e "mysql root password is already setup $Y skipping $N"| tee -a $LOG_FILE
fi


