#!/bin/bash

#Author:George
#Date created:27/02/2024
#Description#:The script approves any transaction </= to Kofi's credit limit


# Kofi's Approved credit Limit
credit_limit=2000

# Transaction input message
read -p "Please Enter your transaction amount: " Entered_transaction_amount

# Check if the entered transaction amount is within the credit limit
if [ "$Entered_transaction_amount" -le "$credit_limit" ]; then
        echo "transaction approved successfully."
elif
      [ "$Entered_transaction_amount" -gt "$credit_limit" ]; then
          echo "Transaction declined: Amount above credit limit."
else
      echo "Sorry Kofi,Your Transaction was declined.Please contact customer care."
fi

