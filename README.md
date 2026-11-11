# Pocket Chess

An Android-only Flutter chess app with local Human vs Human and Human vs Computer games. Computer difficulty is selected on the home screen. The app uses `chess.dart` for legal move generation and Google Mobile Ads for the home banner and interstitial placements.

## Run

```sh
flutter pub get
flutter run
```

The current AdMob application and ad unit IDs are Google's sample test IDs. Replace them with IDs from your AdMob account before publishing. The IDs are configured in `android/app/src/main/AndroidManifest.xml` and `lib/main.dart`.
