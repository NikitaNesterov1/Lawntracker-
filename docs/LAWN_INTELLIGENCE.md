# Lawn Intelligence

The app now has a `Lawn Info` tab for personal lawn context and weather-driven decisions.

## What It Stores Locally

- Property nickname
- Saved place label
- Latitude and longitude, only after the user grants location permission or selects a search result
- Elevation estimate
- Lawn size
- Grass type
- Soil texture
- Slope
- Sun exposure
- Irrigation method
- Preferred mowing height
- Notes
- Last fetched weather snapshot

This data is saved in the app's local `UserDefaults` store. It is not sent anywhere except when weather data is refreshed.

## Weather Data

The app uses Open-Meteo for the first implementation because it does not require API keys, Apple Developer entitlements, or code signing capabilities.

The weather request includes:

- Current temperature, humidity, precipitation, rain, weather code, and wind speed
- Recent daily precipitation estimates using `past_days=7`
- Next 14 days forecast precipitation
- Daily ET0 reference evapotranspiration
- Daily high and low temperature
- Daily precipitation probability

## Location Options

Users can either:

- Tap `Use Current Location`, which uses iOS location permission and reverse geocoding
- Search by city or ZIP, which uses Open-Meteo's geocoding API

## Lawn Relevance

The first version uses weather and lawn facts to show:

- Past 7 days rainfall
- Next 14 days rainfall forecast
- Recent evapotranspiration estimate
- Basic moisture balance
- Watering guidance using the existing lawn recommendation logic

## Rainfall Math

The app keeps separate rainfall sources so totals are easier to trust:

- Logged rain: user-entered rainfall for the last 7 calendar days, including today
- Week-to-date rain: user-entered rainfall from the current calendar week
- Weather estimate: Open-Meteo's previous 7 completed daily rainfall totals
- Rainfall prediction: Open-Meteo's forecast for today plus the next 13 days, with days 8-14 split out

When generating lawn guidance, the app uses logged rainfall first. If the user has not logged rain for the period, it falls back to the weather estimate.

Future versions can add soil temperature, soil moisture, growing degree days, mowing windows, seed germination windows, fertilizer timing, and disease-risk alerts.
