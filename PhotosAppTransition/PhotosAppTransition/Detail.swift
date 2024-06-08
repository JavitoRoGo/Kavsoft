//
//  Detail.swift
//  PhotosAppTransition
//
//  Created by Javier Rodríguez Gómez on 10/5/24.
//

import SwiftUI

struct Detail: View {
	@Environment(UICoordinator.self) private var coordinator
	
	var body: some View {
		VStack(spacing: 0) {
			NavigationBar()
			
			GeometryReader {
				let size = $0.size
				
				ScrollView(.horizontal) {
					LazyHStack(spacing: 0) {
						ForEach(coordinator.items) { item in
							// Imge view
							imageView(item, size: size)
						}
					}
					.scrollTargetLayout()
				}
				// Making it as a paging view
				.scrollTargetBehavior(.paging)
				.scrollIndicators(.hidden)
				.scrollPosition(id: .init(get: {
					return coordinator.detailScrollPosition
				}, set: {
					coordinator.detailScrollPosition = $0
				}))
				.onChange(of: coordinator.detailScrollPosition, {
					coordinator.didDetailPageChanged()
				})
				.background {
					// We can just add the destination anchor as a background to the scrollview, which likewise occupies the full available space, because every item in the destination scrollview takes up the entire available space
					if let selectedItem = coordinator.selectedItem {
						Rectangle()
							.fill(.clear)
							.anchorPreference(key: HeroKey.self, value: .bounds, transform: { anchor in
								return [selectedItem.id + "DEST": anchor]
							})
					}
				}
				.offset(coordinator.offset)
				
				Rectangle()
					.foregroundStyle(.clear)
					.frame(width: 10)
					.contentShape(.rect)
					.gesture(
						DragGesture(minimumDistance: 0)
							.onChanged { value in
								let translation = value.translation
								coordinator.offset = translation
								// Progress for fading out the detail view
								let heightProgress = max(min(translation.height / 200, 1), 0)
								coordinator.dragProgress = heightProgress
							}
							.onEnded { value in
								let translation = value.translation
								let velocity = value.velocity
//								let width = translation.width + (velocity.width / 5)
								let height = translation.height + (velocity.height / 5)
								
								if height > (size.height * 0.5) {
									// Close view
									coordinator.toggleView(show: false)
								} else {
									// Reset to origin
									withAnimation(.easeInOut(duration: 0.2)) {
										coordinator.offset = .zero
										coordinator.dragProgress = 0
									}
								}
							}
					)
			}
			.opacity(coordinator.showDetailView ? 1 : 0)
			
			BottomIndicatorView()
				.offset(y: coordinator.showDetailView ? (120 * coordinator.dragProgress) : 120)
				.animation(.easeInOut(duration: 0.15), value: coordinator.showDetailView)
		}
		.onAppear {
			// This will ensure that the detail view loads and initiates the layer animation. The reason it's not toggled when the item is tapped in Home View is that occasionally, the destination view might not be loaded. In that scenario, the destination anchor will be nil and the layer will not be animated
			coordinator.toggleView(show: true)
		}
	}
	
	@ViewBuilder
	func imageView(_ item: Item, size: CGSize) -> some View {
		if let image = item.image {
			Image(uiImage: image)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: size.width, height: size.height)
				.clipped()
				.contentShape(.rect)
		}
	}
	
	// Custom Navigation bar
	@ViewBuilder
	func NavigationBar() -> some View {
		HStack {
			Button {
				coordinator.toggleView(show: false)
			} label: {
				HStack(spacing: 2) {
					Image(systemName: "chevron.left")
						.font(.title3)
					Text("Back")
				}
			}
			Spacer(minLength: 0)
			Button {
				
			} label: {
				Image(systemName: "ellipsis")
					.padding(10)
					.background(.bar, in: .circle)
			}
		}
		.padding([.top, .horizontal], 15)
		.padding(.bottom, 10)
		.background(.ultraThinMaterial)
		.offset(y: coordinator.showDetailView ? (-120 * coordinator.dragProgress) : -120)
		.animation(.easeInOut(duration: 0.15), value: coordinator.showDetailView)
	}
	
	// Bottom Indicator view
	func BottomIndicatorView() -> some View {
		GeometryReader {
			let size = $0.size
			
			ScrollView(.horizontal) {
				LazyHStack(spacing: 5) {
					ForEach(coordinator.items) { item in
						// Preview image view
						if let image = item.previewImage {
							Image(uiImage: image)
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(width: 50, height: 50)
								.clipShape(.rect(cornerRadius: 10))
								.scaleEffect(0.97)
						}
					}
				}
				.padding(.vertical, 10)
				.scrollTargetLayout()
			}
			.safeAreaPadding(.horizontal, (size.width - 50) / 2)
			.overlay {
				// Active indicator icon
				RoundedRectangle(cornerRadius: 10)
					.stroke(Color.primary, lineWidth: 2)
					.frame(width: 50, height: 50)
					.allowsHitTesting(false)
			}
			.scrollTargetBehavior(.viewAligned)
			.scrollPosition(id: .init(get: {
				return coordinator.detailIndicatorPosition
			}, set: {
				coordinator.detailIndicatorPosition = $0
			}))
			.scrollIndicators(.hidden)
			.onChange(of: coordinator.detailIndicatorPosition) {
				coordinator.didDetailIndicatorPageChanged()
			}
		}
		.frame(height: 70)
		.background {
			Rectangle()
				.fill(.ultraThinMaterial)
				.ignoresSafeArea()
		}
	}
}

#Preview {
    ContentView()
}
