# timesheet_ui

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# command for creat upload_keystore.jks --->" keytool -genkeypair -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
"
# command for create upload-keystore.b64 ----->"[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) > upload-keystore.b64
"

# upload-keystore.jks file is in --->C:\\Users\\DELL\\.keystores\\upload-keystore.jks (for safty purpose) we can keep it in project root but we should not ommit it ,

