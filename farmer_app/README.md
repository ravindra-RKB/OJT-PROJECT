# Farmer App (Bengaluru)

Unified assistance app for farmers around Bengaluru, providing live weather, mandi price updates, farm diary, government schemes, and Firebase-backed authentication.

## Tech Stack
- Flutter
- Firebase Authentication + Cloud Firestore
- Hive (offline diary and caching)
- Provider for state management
- HTTP + official OpenWeatherMap and data.gov.in APIs

## Prerequisites
1. Flutter SDK 3.x
2. Firebase project (Android/iOS config already scaffolded via `firebase_options.dart`)
3. API keys:
   - [OpenWeatherMap](https://openweathermap.org/api) for weather
   - [data.gov.in](https://data.gov.in/user) API key for Agmarknet mandi prices

## Environment Configuration
Create a `.env` file in the project root with the following entries:
```
OPENWEATHER_API_KEY=your_openweather_api_key
DATA_GOV_API_KEY=your_data_gov_api_key
BANGALORE_DEFAULT_CITY=Bengaluru
BANGALORE_DEFAULT_DISTRICT=Bengaluru Urban
BANGALORE_DEFAULT_STATE=Karnataka
```
> The `.env` file is gitignored. If you need a template, copy the snippet above.

## Running the App
1. Install dependencies:
   ```
   flutter pub get
   ```
2. Run on an emulator or device:
   ```
   flutter run
   ```

## Feature Highlights
- **Bengaluru-first data**: default weather + mandi calls target Bengaluru Urban/Karnataka but can be overridden dynamically.
- **Offline diary**: Hive stores farm diary entries locally and sync logic can be extended to Firestore.
- **Connectivity awareness**: UI indicates offline mode and reuses cached data where possible.

## Testing
- Widget tests live in `test/`
- Run: `flutter test`

## Contributing
1. Create a feature branch
2. Follow the code style enforced by `flutter_lints`
3. Add/update tests where relevant
4. Submit a PR with a concise description of the change
