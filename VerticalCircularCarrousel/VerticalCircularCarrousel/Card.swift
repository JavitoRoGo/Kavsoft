//
//  Card.swift
//  VerticalCircularCarrousel
//
//  Created by Javier Rodríguez Gómez on 2/6/24.
//

import SwiftUI

struct Card: Identifiable {
	var id: UUID = .init()
	var number: String
	var name: String = "iJustine"
	var date: String = "12/24"
	var color: Color
}

var cards: [Card] = [
	.init(number: "1234", color: .purple),
	.init(number: "5678", color: .red),
	.init(number: "0987", color: .blue),
	.init(number: "6543", color: .orange),
	.init(number: "1238", color: .black),
	.init(number: "7732", color: .brown),
	.init(number: "9823", color: .cyan)
]
