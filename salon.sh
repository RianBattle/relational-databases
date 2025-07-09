#!/bin/bash

PSQL="psql -X -t --username=freecodecamp --dbname=salon -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ ! -z $1 ]]
  then
    echo -e "$1"
  fi

  ($PSQL "SELECT service_id, name FROM services ORDER BY service_id") | while read SERVICE_ID BAR SERVICE_NAME ;
  do
    if [[ $SERVICE_ID > 0 ]]
    then
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done
  
  read SERVICE_ID_SELECTED
  # SELECTED_SERVICE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if [[ -z $SELECTED_SERVICE_RESULT ]]
  # then
  #   MAIN_MENU "\nI could not find that service. What would you like today?"
  # fi
  SELECTED_SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SELECTED_SERVICE_ID_RESULT ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  fi
  SELECTED_SERVICE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_ID=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    if [[ $INSERT_CUSTOMER_ID != "INSERT 0 1" ]]
    then
      MAIN_MENU "\nUnable to insert new customer record."
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")

  echo -e "\nWhat time would you like your$SELECTED_SERVICE_RESULT,$CUSTOMER_NAME?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a$SELECTED_SERVICE_RESULT at $SERVICE_TIME,$CUSTOMER_NAME."
}

echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU
