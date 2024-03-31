//
//  OrderStatusBundle.swift
//  OrderStatus
//
//  Created by Javier Rodríguez Gómez on 30/3/24.
//

import WidgetKit
import SwiftUI

@main
struct OrderStatusBundle: WidgetBundle {
    var body: some Widget {
        OrderStatus()
        OrderStatusLiveActivity()
    }
}
