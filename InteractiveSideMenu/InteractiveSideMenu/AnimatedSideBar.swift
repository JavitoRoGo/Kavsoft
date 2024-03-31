//
//  AnimatedSideBar.swift
//  InteractiveSideMenu
//
//  Created by Javier Rodríguez Gómez on 26/3/24.
//

import SwiftUI

struct AnimatedSideBar<Content: View, MenuView: View, Background: View>: View {
	// Customization Options
	var rotatesWhenExpands = true
	var disablesInteraction = true
	var sideMenuVidth: CGFloat = 200
	var cornerRadius: CGFloat = 25
	
	@Binding var showMenu: Bool
	@ViewBuilder var content: (UIEdgeInsets) -> Content
	@ViewBuilder var menuView: (UIEdgeInsets) -> MenuView
	@ViewBuilder var background: Background
	
	// View properties
	@GestureState private var isDragging = false
	@State private var offsetX: CGFloat = 0
	@State private var lastOffsetX: CGFloat = 0
	// Used to dim content view when side bar is being dragged
	@State private var progress: CGFloat = 0
	
    var body: some View {
		GeometryReader {
			let size = $0.size
			let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets ?? .zero
			
			HStack(spacing: 0) {
				GeometryReader { _ in
					menuView(safeArea)
				}
				.frame(width: sideMenuVidth)
				// Clipping menu interaction beyond it's width
				.contentShape(.rect)
				
				GeometryReader { _ in
					content(safeArea)
				}
				.frame(width: size.width)
				// let's create an overlay dimming view that will block the interactions with the content view when it's being dragged, and tapping it will hide the side menu
				.overlay {
					if disablesInteraction && progress > 0 {
						Rectangle()
							.fill(.black.opacity(progress * 0.2))
							.onTapGesture {
								withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
									reset()
								}
							}
					}
				}
				.mask {
					RoundedRectangle(cornerRadius: progress * cornerRadius)
				}
				.scaleEffect(rotatesWhenExpands ? 1 - (progress * 0.1) : 1, anchor: .trailing)
				.rotation3DEffect(
					.init(degrees: rotatesWhenExpands ? (progress * -15) : 0),
					axis: (x: 0.0, y: 1.0, z: 0.0)
				)
			}
			.frame(width: size.width + sideMenuVidth, height: size.height)
			.offset(x: -sideMenuVidth)
			.offset(x: offsetX)
			.contentShape(.rect)
			.simultaneousGesture(dragGesture)
		}
		.background(background)
		.ignoresSafeArea()
		.onChange(of: showMenu, initial: true) { oldValue, newValue in
			withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
				if newValue {
					showSideBar()
				} else {
					reset()
				}
			}
		}
    }
	
	// Drag gesture
	var dragGesture: some Gesture {
		DragGesture()
			.updating($isDragging) { _, out, _ in
				out = true
			}.onChanged { value in
				// the edge gesture for the NavigationStack isn't working since our gesture is interfering with it. To avoid this, simply ignore touches on the leading edge
				guard value.startLocation.x > 10 else { return }
				
				// this will limit the translation value from 0 to the side bar width. Thus, it will avoid over dragging the menu view
				let translationX = isDragging ? max(min(value.translation.width + lastOffsetX, sideMenuVidth), 0) : 0
				offsetX = translationX
				calculateProgress()
			}.onEnded { value in
				guard value.startLocation.x > 10 else { return }
				
				withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
					let velocityX = value.velocity.width / 8
					let total = velocityX + offsetX
					
					if total > (sideMenuVidth * 0.5) {
						showSideBar()
					} else {
						reset()
					}
				}
			}
	}
	
	// Shows side bar
	func showSideBar() {
		offsetX = sideMenuVidth
		lastOffsetX = offsetX
		showMenu = true
		calculateProgress()
	}
	
	// Reset's to it's initial state
	func reset() {
		offsetX = 0
		lastOffsetX = 0
		showMenu = false
		calculateProgress()
	}
	
	// Converts offset into Series of progress ranging from 0 - 1
	func calculateProgress() {
		progress = max(min(offsetX / sideMenuVidth, 1), 0)
	}
}

#Preview {
    ContentView()
}
