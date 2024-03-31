//
//  ContentView.swift
//  InteractiveSideMenu
//
//  Created by Javier Rodríguez Gómez on 26/3/24.
//

import SwiftUI

struct ContentView: View {
	// View properties
	@State private var showMenu = false
    var body: some View {
		AnimatedSideBar(rotatesWhenExpands: true, disablesInteraction: true, sideMenuVidth: 200, cornerRadius: 25, showMenu: $showMenu) { safeArea in
			NavigationStack {
				List {
					NavigationLink("Detail View") {
						Text("Hello iJustine")
							.navigationTitle("Detail")
					}
				}
				.navigationTitle("Home")
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button {
							showMenu.toggle()
						} label: {
							Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
								.foregroundStyle(Color.primary)
								.contentTransition(.symbolEffect)
						}
					}
				}
			}
		} menuView: { safeArea in
			SideBarMenuView(safeArea)
		} background: {
			Rectangle()
				.fill(.black.opacity(0.8))
		}
    }
	
	@ViewBuilder
	func SideBarMenuView(_ safeArea: UIEdgeInsets) -> some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Side Menu")
				.font(.largeTitle.bold())
				.padding(.bottom, 10)
			SideBarButton(.home)
			SideBarButton(.bookmark)
			SideBarButton(.favourites)
			SideBarButton(.profile)
			Spacer(minLength: 0)
			SideBarButton(.logout)
		}
		.padding(.horizontal, 15)
		.padding(.vertical, 20)
		.padding(.top, safeArea.top)
		.padding(.bottom, safeArea.bottom)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		.environment(\.colorScheme, .dark)
	}
	
	@ViewBuilder
	func SideBarButton(_ tab: Tab, onTap: @escaping () -> () = {}) -> some View {
		Button {
			onTap()
		} label: {
			HStack(spacing: 12) {
				Image(systemName: tab.rawValue)
					.font(.title3)
				Text(tab.title)
					.font(.callout)
				Spacer(minLength: 0)
			}
			.padding(.vertical, 10)
			.contentShape(.rect)
			.foregroundStyle(Color.primary)
		}
	}
	
	// Sample tab's
	enum Tab: String, CaseIterable {
		case home = "house.fill"
		case bookmark = "book.fill"
		case favourites = "heart.fill"
		case profile = "person.crop.circle"
		case logout = "rectangle.portrait.and.arrow.forward.fill"
		
		var title: String {
			switch self {
				case .home:
					"Home"
				case .bookmark:
					"Bookmark"
				case .favourites:
					"Favourites"
				case .profile:
					"Profile"
				case .logout:
					"Logout"
			}
		}
	}
}

#Preview {
    ContentView()
}
