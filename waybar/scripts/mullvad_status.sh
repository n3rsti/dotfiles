#!/bin/sh

if mullvad status | grep -q "Connected"; then
    relay=$(mullvad status | grep "Relay:" | awk '{print $2}')
    location=$(mullvad status | grep "Visible location:" | cut -d ':' -f2- | xargs)
    echo "{\"text\": \"  $relay\", \"tooltip\": \"$location\"}"
    # echo " $relay ($location)"
else
    echo "{\"text\": \"  Disconnected\", \"tooltip\": \"Disconnected\"}"
fi
