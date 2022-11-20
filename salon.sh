#! /bin/bash

PSQL="psql  --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\n1) cut\n2) color\n3) perm"
  read SERVICE_ID_SELECTED
  
  case $SERVICE_ID_SELECTED in
  1) SERVICE_MENU ;;
  2) SERVICE_MENU ;;
  3) SERVICE_MENU ;;
  *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}



SERVICE_MENU() {
  SELECTED_SERVICE_FOR_DISPLAY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERTED_RESULT_FOR_CUSTOMER=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi
  if [[ -z $CUSTOMER_NAME  ]]
  then
      MAIN_MENU "Please enter a valid name next time"
  else
  echo -e "\nWhat time would you like your $(echo $SELECTED_SERVICE_FOR_DISPLAY | sed 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME
  
  if [[ -z $SERVICE_TIME ]]
  then
    MAIN_MENU "Please enter a valid service time next time"
  else

  CUSTOMER_ID_FOR_APPOINTMENT=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  INSERTED_RESULT_FOR_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID_FOR_APPOINTMENT,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  
  if [[ -z $INSERTED_RESULT_FOR_APPOINTMENT ]]
  then
    MAIN_MENU "Internal server error, sorry for that. Please try again"
  else
  echo -e "\nI have put you down for a $SELECTED_SERVICE_FOR_DISPLAY at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')."
  
  fi
  fi
  fi
}


MAIN_MENU

