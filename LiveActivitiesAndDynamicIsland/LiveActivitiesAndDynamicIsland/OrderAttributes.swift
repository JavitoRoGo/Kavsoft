//
//  OrderAttributes.swift
//  LiveActivitiesAndDynamicIsland
//
//  Created by Javier Rodríguez Gómez on 30/3/24.
//

import ActivityKit
import SwiftUI

struct OrderAttributes: ActivityAttributes {
	struct ContentState: Codable, Hashable {
		// Live activities will update its view when ContentState is updated
		var status: Status = .received
	}
	
	// Other properties
	var orderNumber: Int
	var orderItems: String
}

// Order status, just for this demo project
enum Status: String, CaseIterable, Codable, Equatable {
	case received = "shippingbox.fill"
	case progress = "person.bust"
	case ready = "takeoutbag.and.cup.and.straw.fill"
}
