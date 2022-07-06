

<p align="center">
  <img src="https://i.hizliresim.com/ivxcz1w.png">
</p>


With  Whisper,  we  enable  our  users  to  communicate  from Peer to Peer by  using WebRTC technology. Since we are using Peer to Peer, they can send messages among themselves without a server intermediary, and we cannot access them even if we wanted to. We also encrypt these messages  symmetrically  as  an  extra  security  method. We  aim  to  offer  our  users  a  quality messaging and conversation service with a beautiful design. We are planning to add video chat feature and many more features in our next versions.


### See Live : https://whisperp.web.app

### Thesis link :  [Doc](https://drive.google.com/file/d/11fl197PJLVTyx-urz1BGn8eh2e4JQdFE/view?usp=sharing)

We are using:

- GIT hooks to increase version number before push it the the Github
- Github Actions as CI/CD tool to deploy our project to hositing
- Firebase hosting to serve our demo apps for every step of development


## Development

- We will use git feature branching strategy
  - We will open a branch for all new features and create pull request at the and of this feature's development
  - We will rebase commits to 1 commit for each pull request to keep main branch commit history


## Sources

- [Creating a chat application with WebRTC](https://blog.logrocket.com/creating-chat-application-with-webrtc/)

## History

- Firebase integration 14 May 2022 => https://firebase.google.com/docs/flutter/setup?platform=ios

  - Firebase core -> Usage reason and detail will be added by Serdar
  - Firebase authentication ->
  - Firestore ->
    - Rules are important to modify access level of users to data
  - Storage ->
  - Hosting ->
  - Messaging -> For push notification

- Other packages used in the project

  - [FlutterFire UI](https://pub.dev/packages/flutterfire_ui)
  - [Flutter-WebRTC](https://pub.dev/packages/flutter_webrtc)

- DevOps CI/CD for flutter using Github Actions


## Need to check out

- https://pub.dev/packages/flutter_firebase_chat_core
- https://pub.dev/packages/flutterfire_ui

## Problems

- MacOS internet connection -> https://stackoverflow.com/a/61201081/6378949
- Resume the app from background -> https://stackoverflow.com/a/63506189
- Store data when the app on background -> https://stackoverflow.com/a/63506189
- https://pub.dev/packages/encrypt

## WebRTC

- https://flutter-webrtc.org/
- https://www.100ms.live/blog/flutter-webrtc
- https://youtu.be/ZqvOwCzBxw8
- https://youtu.be/hAKQzNQmNe0

- https://github.com/flutter-webrtc/callkeep
- https://pub.dev/packages/flutter_incoming_call

## Codes and Repos Used in The Project

- https://github.com/abuanwar072/Chat-Messaging-App-Light-and-Dark-Theme

---

Encryption key -> peer's id combination
