//
//  Item.swift
//  StackedCardScrollView
//
//  Created by Javier Rodríguez Gómez on 16/5/24.
//

import SwiftUI

struct Item: Identifiable {
	var id: UUID = .init()
	var logo: String
	var title: String
	var description: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
}

var items: [Item] = [
	.init(logo: "Amazon", title: "person"),
	.init(logo: "Youtube", title: "videoprojector.fill"),
	.init(logo: "Dribbble", title: "book"),
	.init(logo: "Apple", title: "applelogo"),
	.init(logo: "Patreon", title: "dollarsign"),
	.init(logo: "Instagram", title: "camera"),
	.init(logo: "Netflix", title: "tv"),
	.init(logo: "Photoshop", title: "compass.drawing"),
	.init(logo: "Figma", title: "pencil.line"),
]
