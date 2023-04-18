//
//  ContentView.swift
//  PomodoroTimer
//
//  Created by Javier Rodríguez Gómez on 18/5/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pomodoroModel: PomodoroModel
    
    var body: some View {
        Home()
            .environmentObject(pomodoroModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
