//
//  ContentView.swift
//  LiveActivitiesAndDynamicIsland
//
//  Created by Javier Rodríguez Gómez on 30/3/24.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct ContentView: View {
	// Updating live activity
	@State private var currentID = ""
	@State private var currentSelection: Status = .received
	
    var body: some View {
		NavigationStack {
			VStack {
				Picker(selection: $currentSelection) {
					Text("Received")
						.tag(Status.received)
					Text("Progress")
						.tag(Status.progress)
					Text("Ready")
						.tag(Status.ready)
				} label: {
					
				}
				.labelsHidden()
				.pickerStyle(.segmented)
				
				// Initializing activity
				Button("Start Activity") {
					addLiveActivity()
				}
				.padding(.top)
				
				// Removing activity
				Button("Remove Activity") {
					removeActivity()
				}
				.padding(.top)
			}
			.navigationTitle("Live activities")
			.padding(15)
			.onChange(of: currentSelection) {
				// Retreiving current activity from the list of phone activities
				if let activity = Activity.activities.first(where: { (activity: Activity<OrderAttributes>) in
					activity.id == currentID }) {
					print("Activity found")
					// Only for demo purpose, a delay is added
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						var updatedState = activity.contentState
						updatedState.status = currentSelection
						Task {
							await activity.update(using: updatedState)
						}
					}
				}
			}
		}
    }
	
	// We need to add key in Info.plist file
	func addLiveActivity() {
		let orderAttributes = OrderAttributes(orderNumber: 26383, orderItems: "Burger & Milk shake")
		// If the content state struct contains initializers then we must pass it here
		let initialContentState = OrderAttributes.ContentState()
		let activityContent: ActivityContent<OrderAttributes.ContentState> = .init(state: initialContentState, staleDate: nil)
		
		do {
			let activity = try Activity<OrderAttributes>.request(attributes: orderAttributes, content: activityContent)
			print("Activity added successfully, id: \(activity.id)")
			// Storing currentID for updating activity
			currentID = activity.id
		} catch {
			print(error.localizedDescription)
		}
	}
	
	func removeActivity() {
		if let activity = Activity.activities.first(where: { (activity: Activity<OrderAttributes>) in
			activity.id == currentID }) {
			Task {
				await activity.end(using: activity.contentState, dismissalPolicy: .immediate)
			}
		}
	}
}

#Preview {
    ContentView()
}
