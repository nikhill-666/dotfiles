#!/bin/bash

# location ID -q used for city
LOCATION_ID="dereham"
# API key
API_KEY="45adb5ff19b4cb995c21b6839993259c"

# Fetch weather data
WEATHER_DATA=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=$LOCATION_ID&appid=$API_KEY&units=metric")

# Extract relevant information
TEMPERATURE=$(echo "$WEATHER_DATA" | jq -r '.main.temp')
DESCRIPTION=$(echo "$WEATHER_DATA" | jq -r '.weather[0].description' | sed -E 's/\b([a-z])/\u\1/g')

# Extract Data
ICON_ID=$(echo "$WEATHER_DATA" | jq -r '.weather[0].icon')
FEELS=$(echo "$WEATHER_DATA" | jq -r '.main.feels_like')
PRESS=$(echo "$WEATHER_DATA" | jq -r '.main.pressure')
MAX=$(echo "$WEATHER_DATA" | jq -r '.main.humidity')
MIN=$(echo "$WEATHER_DATA" | jq -r '.clouds.all')
WINDS=$(echo "$WEATHER_DATA" | jq -r '.wind.speed')
WINDG=$(echo "$WEATHER_DATA" | jq -r '.wind.gust')

# Calculate temperature in Kelvin
KELVIN=$(echo "$TEMPERATURE + 273.15" | bc)

# Get Last Updtae
UPDATE_TIME_UNIX=$(echo "$WEATHER_DATA" | jq -r '.dt')
UPDATE_TIME=$(date -d "@$UPDATE_TIME_UNIX" +"%H:%M") # Format as HH:MM

# Extract rain data (if present)
RAIN_1H=$(echo "$WEATHER_DATA" | jq -r '.rain."1h"' 2>/dev/null) # 1 hour
RAIN_3H=$(echo "$WEATHER_DATA" | jq -r '.rain."3h"' 2>/dev/null) # 3 hour

# Ignore null response if no rain in area.
if [[ "$RAIN_1H" != "null" && -n "$RAIN_1H" ]]; then
    RAIN_TEXT="Rain in 1hr: $RAIN_1H mm"
elif [[ "$RAIN_3H" != "null" && -n "$RAIN_3H" ]]; then
    RAIN_TEXT="Rain in 3hr: $RAIN_3H mm"
else
    RAIN_TEXT="No rain is due."
fi

# Construct JSON output
echo '{"text": "'"$TEMPERATURE"'°C, '"$DESCRIPTION"', (feels like '"$FEELS"'°C)", "tooltip": "Pressure: '"$PRESS"' hPa\nHumidity: '"$MAX"'%\nCloud cover: '"$MIN"'%\n\n'"$RAIN_TEXT"'\n\nWind Speed: '"$WINDS"'\nWind Gust: '"$WINDG"'\n\nKevin: '"$KELVIN"'\n\nLast Update: '"$UPDATE_TIME"'"}'
