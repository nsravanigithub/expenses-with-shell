#!/bin/bash
Time=$(date +%Y.%m.%d-%H.%M.%S)
scriptname=$( echo $0 | cut -d "." -f1) #it cuts the .sh from script name 
logfile=/tmp/$scriptname.$Time.log
R="\e[31m"
G="\e[32m"

user=$(id -u)
validate()
{
    if [ $1 -ne 0 ]
    then
    echo -e "$2........$R failure $N" 
    exit 1
    else
    echo -e "$2.....$G Success $N"
    fi

}
    if [ $user -ne 0 ]
    then
    echo "Please run with root access"
    exit 1
    else
    echo "you are super user"
    fi

    dnf install mysql-server -y &>>logfile
    validate $? "Installation of mysql"

    systemctl enable mysqld &>>logfile
    validate $? "Enabling mysql server"

    systemctl start mysqld &>>logfile
    validate $? "Starting mqsql server"

    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>logfile
    validate $? "Changing the root password"
