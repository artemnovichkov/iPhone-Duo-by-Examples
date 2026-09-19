# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Project

A SwiftUI-only catalog of runnable examples for the iPhone Duo (foldable iPhone) APIs introduced in iOS 27.1: hinge (`onHingeChange`), reserved regions (`GeometryProxy.reservedRegions`), `ArrangementView` (`.split` / `.overlay`), the vertical bar toolbar APIs, and container content margins. It's published on GitHub as learning material, so code clarity and the README matter as much as behavior. No UIKit examples, by the owner's choice.

## Commands

The Xcode project uses the JSON project format: `iPhoneDuoByExamples.xcodeproj/project.xcproj` (there is no `project.pbxproj`). Files are listed explicitly under `"files"`, grouped by folder. When you add, remove, or rename a source file, edit its entry by hand, for example:

```json
{ "path": "NewExample.swift", "target-membership": [ "iPhoneDuoByExamples/compile-sources" ] },
```

Asset catalogs use `"iPhoneDuoByExamples/resources"`. Build settings live in `"build-settings"`: project-wide at the root, and target-specific inside `"targets"`. Per-configuration values use the `KEY[config=Debug]` form.

Build for the iPhone Duo simulator (Xcode 27.1, iOS 27.1 SDK):

```bash
xcodebuild -project iPhoneDuoByExamples.xcodeproj -scheme iPhoneDuoByExamples \
  -destination 'platform=iOS Simulator,name=iPhone Duo' build
```

There are no tests and no linter.

To run and open one example directly, pass `-example <case>`, where `<case>` is a raw value of the `Example` enum:

```bash
xcrun simctl launch booted com.artemnovichkov.iPhoneDuoByExamples -example hingeAngle
```

The iPhone Duo simulator has two displays. `xcrun simctl io booted screenshot` captures the inner display; add `--display=1` for the outer (cover) display. Only the active display has content; the other is black (folded → outer, open → inner). Fold state can't be changed from the command line or the device-interaction tools. Ask the user to fold, unfold, or half-fold the simulator. Device-interaction sessions bind to the outer display, so taps don't reach the inner display.

## Architecture

- `Catalog/Example.swift` is the single registry. Each `Example` case supplies its section, title, summary, SF Symbol, API list, and destination view. The in-app "View Source" link is built from the raw value: case `fooBar` → `Examples/FooBarExample.swift`. A new example needs a case here and a file whose name follows that pattern.
- `Catalog/CatalogView.swift` is a `NavigationSplitView`. It hides the sidebar when an example is selected and shows it when none is.
- `Catalog/ExampleScreen.swift` wraps each example with a title and an "About" sheet.
- `Examples/` has one self-contained file per example; each file also needs an entry in `project.xcproj`. Each starts with a doc comment explaining the API, and the key lines are marked with `// 👇 The API:`. Keep that convention.
- `Components/` holds shared views and `DeviceHinge` display helpers.

Build settings: Swift 6, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Custom `Shape` types must be declared `nonisolated struct`, or the `Shape` conformance fails to compile.

## API Behavior Observed on the Simulator

These are verified findings that the README's "Good to Know" section also documents. Keep the code and README consistent with them.

- Reserved regions arrive after the first layout pass. Read them inside the `GeometryReader` body, and don't cache them.
- The division region (the fold) is active only when the device is partially folded. When the device is flat, it's inactive. The outer display reports no regions at all.
- In `.overlay`, the primary view is the foreground. It goes side by side when the device is partially folded.
- `overlayArrangementZIndex` is only visible from a subview of the primary or secondary content. The root content view always reads 0.
- `.split` hides the secondary view when both views don't fit along an allowed axis. In book pose, it places its divider on the fold.
- `splitArrangementAxis` was always `nil`.
- Apple's guidance: use the hinge for effects and interactions, and use reserved regions and arrangements for layout. That's why Tabletop & Book is driven by regions, not by the hinge status.

## README

The README screenshots live in `.github/images/`, named after the example's case (`-folded` and `-book` suffixes mark the fold state). When an example is renamed or added, update its image and the README table row, and check that every referenced path exists.
