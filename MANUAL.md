# VulnaBank manual

## Requirements

- Xcode 27 or later with an iOS 17.5 simulator runtime.
- Network access to the hosted origin, or a local backend (see Backend below).

## Build and run

1. Open `vulnabankIOs.xcodeproj` in Xcode.
2. Select the `vulnabankIOs` scheme and a simulator.
3. Run with Command-R.

## Exercise

1. The first launch shows the registration form; enter a four-digit PIN and
   confirm it.
2. The transaction list appears; the toolbar `+` opens the new-transaction form.
3. Enter a recipient and an amount, then Send. The new transaction appears in
   the list.
4. Swipe a row to delete it, or use Edit to select several rows and Delete.
5. Send the app to the background and back: the login form appears again; log in
   with the PIN.

## Backend

The endpoint is the `LabVulnaBankURL` value in `vulnabankIOs/Info.plist`. The
checked-in `Config/Hosted.xcconfig` points it at the shared hosted origin
(`https://zsk.labs.def.dev/secure-communication/request`), which is what a
Simulator run uses by default. To run against a local server instead:

1. In the server repository, run `make run` (plain HTTP on `:8090`).
2. Copy `Config/Local.example.xcconfig` to the gitignored
   `Config/Local.xcconfig`; `Hosted.xcconfig` includes it optionally, so the app
   needs no Xcode change while that file exists. Delete it to return to the
   hosted endpoint.

The simulator reaches the host's `localhost`, so no additional configuration is
needed.

## Tests

Run with Command-U, or:

```sh
xcodebuild test -project vulnabankIOs.xcodeproj \
  -scheme vulnabankIOs -destination 'id=<simulator-udid>'
```
