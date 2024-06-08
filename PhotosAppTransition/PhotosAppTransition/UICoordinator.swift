//
//  UICoordinator.swift
//  PhotosAppTransition
//
//  Created by Javier Rodríguez Gómez on 10/5/24.
//

import SwiftUI

@Observable
final class UICoordinator {
	var items: [Item] = sampleItems.compactMap {
		Item(title: $0.title, image: $0.image, previewImage: $0.image)
	}
	// Animation properties
	var selectedItem: Item?
	var animateView = false
	var showDetailView = false
	// Scroll positions
	var detailScrollPosition: String?
	var detailIndicatorPosition: String?
	// Gesture properties
	var offset: CGSize = .zero
	var dragProgress: CGFloat = 0
	
	func didDetailPageChanged() {
		if let updatedItem = items.first(where:  { $0.id == detailScrollPosition }) {
			selectedItem = updatedItem
			withAnimation(.easeInOut(duration: 0.1)) {
				detailIndicatorPosition = updatedItem.id
			}
		}
	}
	
	func didDetailIndicatorPageChanged() {
		if let updatedItem = items.first(where:  { $0.id == detailIndicatorPosition }) {
			selectedItem = updatedItem
			// Updating detail paging view as well
			detailScrollPosition = updatedItem.id
		}
	}
	
	func toggleView(show: Bool) {
		if show {
			// This will trigger the detail scrollview to scroll to the selected item
			detailScrollPosition = selectedItem?.id
			// This ensures that the bottom carousel always starts with the selected item
			detailIndicatorPosition = selectedItem?.id
			withAnimation(.easeInOut(duration: 0.2), completionCriteria: .removed) {
				animateView = true
			} completion: {
				self.showDetailView = true
			}
		} else {
			showDetailView = false
			withAnimation(.easeInOut(duration: 0.2), completionCriteria: .removed) {
				animateView = false
				offset = .zero
			} completion: {
				self.resetAnimationProperties()
			}
		}
	}
	
	func resetAnimationProperties() {
		selectedItem = nil
		detailScrollPosition = nil
		offset = .zero
		dragProgress = 0
		detailIndicatorPosition = nil
	}
}
