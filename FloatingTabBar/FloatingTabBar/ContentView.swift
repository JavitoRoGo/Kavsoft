//
//  ContentView.swift
//  FloatingTabBar
//
//  Created by Javier Rodríguez Gómez on 20/1/24.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var tabModel: TabModel = .init()
	// This is needed to tell SwiftUI the window is active
	@Environment(\.controlActiveState) private var state
	
    var body: some View {
		TabView(selection: $tabModel.activeTab) {
			NavigationStack {
				Text("Home View")
					.toolbar {
						ToolbarItem(placement: .primaryAction) {
							Button("", systemImage: "sidebar.left") {
								tabModel.hideTabBar.toggle()
							}
						}
					}
			}
			.tag(Tab.home)
			.background(HideTabBar())
			
			Text("Favorites View")
				.tag(Tab.favorites)
			
			Text("Notifications View")
				.tag(Tab.notifications)
			
			Text("Settings View")
				.tag(Tab.settings)
		}
		.opacity(tabModel.isTabBarAdded ? 1 : 0)
		.background {
			GeometryReader {
				let rect = $0.frame(in: .global)
				Color.clear
					.customOnChange(value: rect) { _ in
						// Frame changed
						tabModel.updateTabPosition()
					}
			}
		}
		.customOnChange(value: state, initial: true) { newValue in
			if newValue == .key {
				tabModel.addTabBar()
			}
		}
		.frame(minWidth: 100, minHeight: 200)
		.padding(.bottom, tabModel.isTabBarAdded ? 0 : 1)
    }
}

// let's write a custom onChange modifier that will support both macOS 13 and 14
extension View {
	@ViewBuilder
	func customOnChange<Value: Equatable>(value: Value, initial: Bool = false, result: @escaping (Value) -> ()) -> some View {
		if #available(macOS 14, *) {
			self
				.onChange(of: value, initial: initial) { oldValue, newValue in
					result(newValue)
				}
		} else {
			self
				.onChange(of: value, perform: result)
				.onAppear {
					if initial {
						result(value)
					}
				}
		}
	}
	
	@ViewBuilder
	func windowBackground() -> some View {
		if #available(macOS 14, *) {
			self
				.background(.windowBackground)
		} else {
			self
				.background(.background)
		}
	}
}

#Preview {
    ContentView()
}


class TabModel: ObservableObject {
	@Published var activeTab: Tab = .home
	@Published private(set) var isTabBarAdded = false
	@Published var hideTabBar = false
	
	private let id: String = UUID().uuidString
	
	func addTabBar() {
		guard !isTabBarAdded else { return }
		
		if let applicationWindow = NSApplication.shared.mainWindow {
			let customTabBar = NSHostingView(rootView: FloatingTabBarView().environmentObject(self))
			let floatingWindow = NSWindow()
			floatingWindow.styleMask = .borderless
			floatingWindow.contentView = customTabBar
			floatingWindow.backgroundColor = .clear
			// this title is used to find the attached window for future purposes
			floatingWindow.title = id
			
			// fixing the location
			let windowSize = applicationWindow.frame.size
			let windowOrigin = applicationWindow.frame.origin
			floatingWindow.setFrameOrigin(.init(x: windowOrigin.x - 50, y: windowOrigin.y + (windowSize.height - 180) / 2))
			
			// Adding above the application window
			applicationWindow.addChildWindow(floatingWindow, ordered: .above)
			
			// this will limit the tab bar to being added only once for the main window
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
				self?.isTabBarAdded = true
			}
		} else {
			print("No window found")
		}
	}
	
	// fixing positioning when resizing the window
	func updateTabPosition() {
		if let floatingWindow = NSApplication.shared.windows.first(where: { $0.title == id }),
		   let applicationWindow = NSApplication.shared.mainWindow {
			let windowSize = applicationWindow.frame.size
			let windowOrigin = applicationWindow.frame.origin
			floatingWindow.setFrameOrigin(.init(x: windowOrigin.x - 50, y: windowOrigin.y + (windowSize.height - 180) / 2))
		}
	}
}

// Tabs
enum Tab: String, CaseIterable {
	case home = "house.fill"
	case favorites = "suit.heart.fill"
	case notifications = "bell.fill"
	case settings = "gearshape"
}

// Floating TabBar View
fileprivate struct FloatingTabBarView: View {
	@EnvironmentObject private var tabModel: TabModel
	@Environment(\.colorScheme) private var colorScheme
	@Namespace private var animation
	private let animationID: UUID = .init()
	
	var body: some View {
		VStack(spacing: 0) {
			ForEach(Tab.allCases, id: \.rawValue) { tab in
				Button {
					tabModel.activeTab = tab
				} label: {
					Image(systemName: tab.rawValue)
						.font(.title3)
						.foregroundStyle(tabModel.activeTab == tab ? (colorScheme == .dark ? .black : .white) : .primary)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background {
							if tabModel.activeTab == tab {
								Circle()
									.fill(.primary)
								// adding matched geometry effect for smooth transition
									.matchedGeometryEffect(id: animationID, in: animation)
							}
						}
						.containerShape(.rect)
						.animation(.bouncy, value: tabModel.activeTab)
				}
				.buttonStyle(.plain)
			}
		}
		.padding(5)
		.frame(width: 45, height: 180)
		.windowBackground()
		.clipShape(.capsule)
		.frame(maxWidth: .infinity, alignment: .leading)
		.frame(width: 50)
		.contentShape(.capsule)
		.offset(x: tabModel.hideTabBar ? 60 : 0)
		.animation(.snappy, value: tabModel.hideTabBar)
	}
}

// Hiding macOS default tab bar
fileprivate struct HideTabBar: NSViewRepresentable {
	func makeNSView(context: Context) -> NSView {
		return .init()
	}
	
	func updateNSView(_ nsView: NSView, context: Context) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
			if let tabView = nsView.superview?.superview?.superview as? NSTabView {
				tabView.tabViewType = .noTabsNoBorder
				tabView.tabViewBorderType = .none
				tabView.tabPosition = .none
			}
		}
	}
}
