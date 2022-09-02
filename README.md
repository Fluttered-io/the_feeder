# The Feeder

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]

A project to show a 'TikTok like' feed.

---

## Getting Started 🚀

To run the project either use the launch configuration in VSCode/Android Studio or use the following commands:


```sh
$ flutter run
```

## Architecture 🏗

The project uses a **feature oriented** architecture for the presentation layer and a domain oriented architecture for the **data layer**.

The presentation layer is under the “lib” folder and the data layer is under the “packages” folder.

### The presentation layer

In this layer we manage the state of the app with the BLoC pattern. Here you can find more information about this pattern and the library that we are using to handle it:

[Bloc State Management Library](https://bloclibrary.dev)

### The data layer

The project uses **repositories** to handle the data entities that the presentation layer it’s going to consume, and API clients or third party services integrations to receive and send the information.


# 📖 Third party libraries

## Freezed

Used to reduce the lines of code that we have to write.

[freezed | Dart Package](https://pub.dev/packages/freezed)

## Video Player

[video_player | Dart Package](https://pub.dev/packages/video_player)
Used to play the videos that we get from the API.


_\*The Feeder works on iOS and Android._

---


[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
