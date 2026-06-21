# Building Without Owning a Mac

You cannot compile or run an iOS simulator app directly on Windows because Apple's iOS toolchain is delivered through Xcode on macOS. The workaround is to keep editing on Windows and use a cloud macOS runner for builds.

## Recommended Path

Use the included GitHub Actions workflow:

1. Push this folder to a GitHub repository.
2. Open the repository's Actions tab.
3. Run `iOS Simulator Build`.
4. Download the `BushkillLawnTracker-simulator-app` artifact after a successful run.

The workflow runs on GitHub's `macos-26` runner, prints the installed Xcode/SDK versions, selects the newest available iOS simulator, and builds `BushkillLawnTracker.xcodeproj` with signing disabled for simulator output.

## What This Solves

- Confirms the SwiftUI app compiles with Xcode.
- Confirms the Xcode project, scheme, assets, and bundled resources are wired correctly.
- Produces a simulator `.app` build artifact.

## What Still Needs Apple Infrastructure

- Running the app interactively in Simulator requires access to a Mac session.
- Installing on a real iPhone requires code signing.
- TestFlight or App Store distribution requires Apple Developer Program membership.

## Next Step After CI Passes

If you want device or TestFlight builds without buying a Mac, use a hosted Mac service or Apple's Xcode Cloud. Keep GitHub Actions for quick compile checks, then add signing only when you are ready to test on a real iPhone.
