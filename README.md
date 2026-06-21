# Bushkill Lawn Tracker

An iOS SwiftUI app for tracking lawn care, weather, rainfall, watering, work logs, seasonal tasks, and plant inventory.

GitHub repository target: `https://github.com/NikitaNesterov1/Lawntracker-.git`

## Current MVP

- Dashboard with property profile and lawn-care recommendation
- Lawn Info tab for location, lawn basics, weather, forecast, rainfall totals, and moisture balance
- Rainfall log with 7-day total calculation
- Watering log with recent watering summary
- Mowing/trimming log, including weed-whacker-only notes
- Seasonal plan through winter and spring 2027
- Plant inventory for lawn-adjacent landscaping
- Local persistence using UserDefaults and JSON encoding
- Weather estimates from Open-Meteo, with no API key required for the initial implementation

## How to build without a Mac

This repository includes a GitHub Actions workflow at `.github/workflows/ios-simulator-build.yml`. Run `iOS Simulator Build` from the Actions tab to build the app on a hosted macOS runner.

To preview the UI from Windows, run `iOS Screenshot Preview` from the Actions tab. It launches the app on a hosted iOS Simulator, captures one screenshot per tab, and uploads the PNG files as an artifact.

See `docs/NO_MAC_BUILD_PLAN.md` for the full Windows-to-cloud build path.
See `docs/PUSH_TO_GITHUB.md` for repo-specific upload steps.
See `docs/LAWN_INTELLIGENCE.md` for the location and weather feature notes.

## Privacy note

The app stores lawn and location details locally on the device. Location data is only collected when the user grants iOS location permission or chooses a searched location. Weather refreshes send coordinates to Open-Meteo to retrieve forecast and rainfall estimates.
