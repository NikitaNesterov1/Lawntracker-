# Product Spec: Bushkill Lawn Tracker

## Problem

The lawn needs a reliable operating system: rainfall tracking, watering decisions, mowing guidance, fall renovation planning, and plant inventory all in one place.

## MVP user stories

- As the owner, I can open the app and see whether I should water, mow, or leave the lawn alone.
- As the owner, I can enter rainfall amounts while away from home.
- As the owner, I can record watering events, mowing/trimming, seeding, and fertilizer.
- As the owner, I can see the seasonal plan for summer survival and fall renovation.
- As the owner, I can maintain an inventory of lawn-adjacent plants and trees.

## Core dashboard metrics

- 7-day rainfall total.
- Last rainfall amount and date.
- Last watering date.
- Current lawn phase.
- Recommendation: water, do not water, monitor, or mow high.

## Recommendation rules v1

- If 7-day rainfall plus confirmed watering is at least 1 inch: do not water.
- If 7-day rainfall is below 0.5 inch and there has been no deep watering in 5+ days: recommend deep watering.
- If the lawn is heat stressed: avoid mowing/trimming unless necessary.
- If in late August to early September: prepare for overseeding workflow.
- If new seed is active: keep seedbed consistently moist, but avoid runoff on slope.

## Future integrations

- Apple WeatherKit for forecast/current weather.
- NWS/NOAA rainfall estimate references.
- CSV import/export from the master workbook.
- PhotosPicker for lawn photo log.
- Calendar reminders for fall renovation and winterizer fertilizer.
