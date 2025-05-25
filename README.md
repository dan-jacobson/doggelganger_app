# doggelganger_app

An app for finding your canine lookalike!

## Running the App

To run the app in `dev` mode, pointing at `0.0.0.0:8000`, use the following command:
`flutter run --dart-define=dev=true`

To run the app in `prod` mode, which points at the current backend on Google Cloud Run:
`flutter run`

## Building and releasing the App

We use `fastlane` to build and release our app to both Apple's App Store and the Google Play Store

For ios, first `cd ios`, then run:
`fastlane ios beta`

If you want to see all the lane options, just run `fastlane`.