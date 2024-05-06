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
    dnf module disable nodejs -y &>>logfile
    validate $? "disabling default nodejs"

    dnf module enable nodejs:20 -y &>>logfile
    validate $? "enabling nodejs 20 version"

    dnf install nodejs -y &>>logfile
    validate $? "installing nodejs 20 version"

    id expense &>/dev/null || useradd expense #it will create user expense/if already exits then it will exit
rm -rf /app
 mkdir -p /app
validate $? "creating add directory"

 curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip   
validate $? "Downloading backend code"

cd /app

unzip /tmp/backend.zip
validate $? "Unzipping the code"
cd /app
npm install
validate $? "Installing nodejs dependencies"

cp /home/ec2-user/expenses-with-shell/backend.service /etc/systemd/system/backend.service
validate $? "Copied backend service"

systemctl daemon-reload
systemctl start backend
systemctl enable backend

dnf install mysql -y
validate $? "Installing mysql client"

mysql -h db.devops4srav.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
validate $? "Loading the schema"

systemctl restart backend


