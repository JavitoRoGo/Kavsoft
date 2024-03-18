//
//  Item.swift
//  StackedCards
//
//  Created by Javier Rodríguez Gómez on 6/3/24.
//

import SwiftUI

struct Item: Identifiable {
	var id: UUID = .init()
	var color: Color
}

extension [Item] {
	// Necesario para preservar el orden al hacer el stacked
	func zIndex(_ item: Item) -> CGFloat {
		if let index = firstIndex(where: { $0.id == item.id }) {
			return CGFloat(count) - CGFloat(index)
		}
		return .zero
	}
}

var items: [Item] = [
	.init(color: .red),
	.init(color: .blue),
	.init(color: .green),
	.init(color: .yellow),
	.init(color: .pink),
	.init(color: .purple)
]
