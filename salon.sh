#!/bin/bash


PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e '\n~~~~~ MY SALON ~~~~~\n'

MAIN_MENU() {

  if [[ ! -z $1 ]]; then
    echo -e "\n$1"
  fi

  # display list of services
  SERVICES=$($PSQL "select service_id, name from services")
  echo "$SERVICES" | while read -r ID BAR NAME 
  do
    echo "$ID) $NAME"
  done

  # read user option
  read SERVICE_ID_SELECTED 

  #if option not number
  if [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    MAIN_MENU "Sorry, that's not a valid option"

    else
      #find the service
      SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")

      # if not find
      if [[ -z $SERVICE_ID ]]; then
        MAIN_MENU "I could not find that service. What would you like today?"
        
        # get phone number
        else
          SERVICE_NAME=$($PSQL "select name from services where service_id='$SERVICE_ID'")
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE

          if [[ -z $CUSTOMER_PHONE ]]; then 
            MAIN_MENU "Sorry, that's not a valid phone number"

            #find id
            else
            CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

            #if not find 
            if [[ -z $CUSTOMER_ID ]]; then
              echo -e "\nI don't have a record for that phone number, what's your name?"
              read CUSTOMER_NAME

              if [[ -z $CUSTOMER_NAME ]]; then
                MAIN_MENU "that's not a valid name"
                else
                  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
                  read SERVICE_TIME 

                  if [[ -z $SERVICE_TIME ]]; then
                    MAIN_MENU "that's not a valid time"
                    else
                      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
                      CUSTOMER_ID=$($PSQL "select customer_id from customers where name='$CUSTOMER_NAME' and phone='$CUSTOMER_PHONE'")
                      if [[ "$INSERT_CUSTOMER_RESULT" == "INSERT 0 1" ]]; then
                        INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(service_id,customer_id,time) values('$SERVICE_ID','$CUSTOMER_ID','$SERVICE_TIME')")

                        if [[ "$INSERT_APPOINTMENT_RESULT" == "INSERT 0 1" ]]; then
                          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
                        fi
                        else
                          MAIN_MENU "Something goes wrong"
                      fi
                  fi
              fi

              #if find
              else
              echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
              read SERVICE_TIME 

              if [[ -z $SERVICE_TIME ]]; then
                MAIN_MENU "that's not a valid time"
                else
                  INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(service_id,customer_id,time) values('$SERVICE_ID','$CUSTOMER_ID','$SERVICE_TIME')")
                  if [[ "$INSERT_APPOINTMENT_RESULT" == "INSERT 0 1" ]]; then
                    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
                    else
                      MAIN_MENU "Something goes wrong"
                  fi
                fi
              fi
        fi
      fi
  fi
}


EXIT_MENU() {
  echo -e '\nWelcome to My Salon, how can I help you?'
}

MAIN_MENU "Welcome to My Salon, how can I help you?"
