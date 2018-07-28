#!/bin/bash
cd /var/www/app
chmod +x artisan

sleep 300s
while /bin/true; do
    ./artisan ninja:send-invoices
    ./artisan ninja:send-reminders
    sleep 1h
done
