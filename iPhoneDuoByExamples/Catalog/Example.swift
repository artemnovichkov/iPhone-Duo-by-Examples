import SwiftUI

/// A group of related examples shown as a section in the catalog.
enum ExampleSection: String, CaseIterable, Identifiable {
    case hinge = "Hinge"
    case reservedRegions = "Reserved Regions"
    case arrangements = "Arrangements"
    case barsAndMargins = "Bars & Margins"
    case adaptivity = "Adaptivity"
    case scenes = "Scenes & Displays"

    var id: Self { self }

    var examples: [Example] {
        Example.allCases.filter { $0.section == self }
    }
}

/// Every example in the app. Each case knows how to describe itself and which view to show.
enum Example: String, CaseIterable, Identifiable, Hashable, Codable {
    case hingeAngle
    case hingeHistory
    case reservedRegions
    case avoidDivision
    case tabletop
    case evenColumns
    case splitArrangement
    case overlayArrangement
    case dualPanePatterns
    case customArrangement
    case verticalToolbar
    case toolbarPriority
    case containerMargins
    case foldedUnfolded
    case safeAreas
    case splitViewSide
    case coverAccessory

    var id: Self { self }

    var section: ExampleSection {
        switch self {
        case .hingeAngle, .hingeHistory: .hinge
        case .reservedRegions, .avoidDivision, .tabletop, .evenColumns: .reservedRegions
        case .splitArrangement, .overlayArrangement, .dualPanePatterns, .customArrangement: .arrangements
        case .verticalToolbar, .toolbarPriority, .containerMargins: .barsAndMargins
        case .foldedUnfolded, .safeAreas: .adaptivity
        case .splitViewSide, .coverAccessory: .scenes
        }
    }

    var title: String {
        switch self {
        case .hingeAngle: "Hinge Angle"
        case .hingeHistory: "Angle History"
        case .reservedRegions: "Reserved Regions"
        case .avoidDivision: "Avoid the Crease"
        case .tabletop: "Tabletop & Book"
        case .evenColumns: "Even Columns"
        case .splitArrangement: "Split Arrangement"
        case .overlayArrangement: "Overlay Arrangement"
        case .dualPanePatterns: "Dual-Pane Patterns"
        case .customArrangement: "Custom Arrangement Style"
        case .verticalToolbar: "Vertical Toolbar"
        case .toolbarPriority: "Overflow & Priority"
        case .containerMargins: "Container Margins"
        case .foldedUnfolded: "Folded & Unfolded"
        case .safeAreas: "Safe Areas"
        case .splitViewSide: "Split View Side"
        case .coverAccessory: "Cover Display Accessory"
        }
    }

    var summary: String {
        switch self {
        case .hingeAngle:
            "Read the live hinge angle with onHingeChange and mirror it in a 3D model of the device."
        case .hingeHistory:
            "Record hinge updates over time and plot them with Swift Charts."
        case .reservedRegions:
            "Query occlusion and division regions from GeometryProxy and draw them on top of your UI."
        case .avoidDivision:
            "Lay out a two-page reader so that no content falls into the division region."
        case .tabletop:
            "Move a media player's controls away from the fold using the active division region."
        case .evenColumns:
            "Use the inactive division region to give a grid an even number of columns with a gutter over the fold."
        case .splitArrangement:
            "Place two views side by side with ArrangementView and tune the ratio between them."
        case .overlayArrangement:
            "Float a panel over full-bleed content and collapse it with overlayArrangementZIndex while it covers the content."
        case .dualPanePatterns:
            "List–detail, companion pane, and extended canvas: three common layouts built with ArrangementView and its sizing modifiers."
        case .customArrangement:
            "Write your own ArrangementViewStyle that places the primary and secondary views on either side of the fold."
        case .verticalToolbar:
            "Control the vertical bar: opt out, choose compression behavior and item axis behavior."
        case .toolbarPriority:
            "Add toolbar items one by one and watch visibilityPriority decide which ones overflow first."
        case .containerMargins:
            "Align content to the container's margins with the new container content margin guide."
        case .foldedUnfolded:
            "React to size changes when the device folds and unfolds using size classes and container size."
        case .safeAreas:
            "Draw the safe area insets on each edge and see how the vertical bar makes them asymmetric."
        case .splitViewSide:
            "Find out which half of the inner display a Split View window is on, and keep two windows in sync."
        case .coverAccessory:
            "Show a second scene on the cover display while the camera runs, with CameraCaptureAccessory."
        }
    }

    var symbol: String {
        switch self {
        case .hingeAngle: "rotate.3d"
        case .hingeHistory: "chart.xyaxis.line"
        case .reservedRegions: "rectangle.dashed"
        case .avoidDivision: "book.pages"
        case .tabletop: "laptopcomputer"
        case .evenColumns: "square.grid.2x2"
        case .splitArrangement: "rectangle.split.2x1"
        case .overlayArrangement: "square.on.square"
        case .dualPanePatterns: "rectangle.righthalf.inset.filled"
        case .customArrangement: "paintbrush.pointed"
        case .verticalToolbar: "sidebar.left"
        case .toolbarPriority: "ellipsis.circle"
        case .containerMargins: "square.dashed.inset.filled"
        case .foldedUnfolded: "arrow.left.and.right.square"
        case .safeAreas: "inset.filled.rectangle"
        case .splitViewSide: "rectangle.split.2x1.fill"
        case .coverAccessory: "camera.on.rectangle"
        }
    }

    var tint: Color {
        switch section {
        case .hinge: .indigo
        case .reservedRegions: .pink
        case .arrangements: .teal
        case .barsAndMargins: .orange
        case .adaptivity: .green
        case .scenes: .purple
        }
    }

    /// The APIs this example demonstrates.
    var apis: [String] {
        switch self {
        case .hingeAngle: ["onHingeChange(isEnabled:_:)", "DeviceHingeContext", "DeviceHinge.angle"]
        case .hingeHistory: ["onHingeChange(isEnabled:_:)", "DeviceHinge"]
        case .reservedRegions: ["GeometryProxy.reservedRegions(kind:options:)", "ReservedRegion.Kind", "ReservedRegion.QueryOptions"]
        case .avoidDivision: ["GeometryProxy.reservedRegions(kind:)", "ReservedRegion.Kind.division"]
        case .tabletop: ["GeometryProxy.reservedRegions(kind:)", "ReservedRegion.isActive"]
        case .evenColumns: ["GeometryProxy.reservedRegions(kind:options:)", "ReservedRegion.QueryOptions.includeInactive"]
        case .splitArrangement: ["ArrangementView", "arrangementViewStyle(.split)", "splitArrangementLayoutRatio(_:)", "splitArrangementAxis"]
        case .overlayArrangement: ["ArrangementView", "arrangementViewStyle(.overlay)", "overlayArrangementEdge(_:)", "overlayArrangementZIndex"]
        case .dualPanePatterns: ["splitArrangementLayoutRatio(minHorizontal:idealHorizontal:…)", "splitArrangementLayoutSize(minWidth:idealWidth:maxWidth:…)", "splitArrangementFixedLayoutSize(horizontal:vertical:)", "OverlayArrangementViewStyle.axes(_:)"]
        case .customArrangement: ["ArrangementViewStyle", "ArrangementViewStyleConfiguration", "arrangementViewStyle(_:)", "GeometryProxy.reservedRegions(kind:options:)"]
        case .verticalToolbar: ["toolbarVerticalBehavior(_:)", "toolbarVerticalCompressionBehavior(_:)", "axisBehavior(_:)", "visibilityPriority(_:)", "ToolbarOverflowMenu", "toolbarVerticalEdge"]
        case .toolbarPriority: ["visibilityPriority(_:)", "ToolbarItemVisibilityPriority(higherThan:)", "ToolbarItemPlacement.topBarPinnedTrailing", "ToolbarOverflowMenu"]
        case .containerMargins: ["contentMargins(for:edges:alignment:)", "ContentMarginGuide.container", "GeometryProxy.contentMargins(for:)"]
        case .foldedUnfolded: ["horizontalSizeClass", "onGeometryChange(for:of:action:)"]
        case .safeAreas: ["GeometryProxy.safeAreaInsets", "toolbarVerticalEdge"]
        case .splitViewSide: ["GeometryProxy.reservedRegions(kind:options:layoutDirectionBehavior:)", "toolbarVerticalEdge", "openWindow(value:)"]
        case .coverAccessory: ["sceneAccessory(content:)", "CameraCaptureAccessory", "onAvailabilityChange(perform:)", "AVCaptureSession"]
        }
    }

    /// Path of the example's source file, used for the "View Source" link.
    var sourcePath: String {
        "iPhoneDuoByExamples/Examples/\(fileName).swift"
    }

    private var fileName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst() + "Example"
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .hingeAngle: HingeAngleExample()
        case .hingeHistory: HingeHistoryExample()
        case .reservedRegions: ReservedRegionsExample()
        case .avoidDivision: AvoidDivisionExample()
        case .tabletop: TabletopExample()
        case .evenColumns: EvenColumnsExample()
        case .splitArrangement: SplitArrangementExample()
        case .overlayArrangement: OverlayArrangementExample()
        case .dualPanePatterns: DualPanePatternsExample()
        case .customArrangement: CustomArrangementExample()
        case .verticalToolbar: VerticalToolbarExample()
        case .toolbarPriority: ToolbarPriorityExample()
        case .containerMargins: ContainerMarginsExample()
        case .foldedUnfolded: FoldedUnfoldedExample()
        case .safeAreas: SafeAreasExample()
        case .splitViewSide: SplitViewSideExample()
        case .coverAccessory: CoverAccessoryExample()
        }
    }
}
