# Weather and Rainfall Integration Plan

## Phase 1: manual entry

Start with manual rainfall entry because estimated rainfall can miss thunderstorms and elevation effects in the Poconos. A physical rain gauge at the property should be treated as the source of truth when available.

## Phase 2: WeatherKit

Apple WeatherKit can provide current conditions, hourly forecasts, daily forecasts, precipitation, and weather alerts. Use this for forecasts and decision support, not as the only rainfall ledger.

Implementation idea:

- Add `WeatherServiceProtocol`.
- Add `MockWeatherService` for previews/tests.
- Add `WeatherKitService` behind a compile flag or availability check.
- Store fetched forecast summaries separately from confirmed rainfall logs.

## Phase 3: rainfall estimates

For historical rainfall estimates, add external references only after deciding on a source. Potential sources include NOAA/NWS products or third-party rainfall estimate APIs. Keep manual corrections available.

## Data philosophy

- Forecasts help decide what to do next.
- Rain gauge or confirmed manual entries become the permanent lawn record.
- Estimated rainfall should be labeled as estimated.
