//
//  BaseView.swift
//  BarGraphs
//
//  Created by Javier Rodríguez Gómez on 20/3/22.
//

import SwiftUI

struct BaseView: View {
    // Using image names as Tab...
    @State var currentTab = "home"
    
    // Hiding native one...
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack {
            // Tab view...
            TabView(selection: $currentTab) {
                Home()
                    .modifier(BGModifier())
                    .tag("home")
                
                Text("Graph")
                    .modifier(BGModifier())
                    .tag("graph")
                
                Text("Chat")
                    .modifier(BGModifier())
                    .tag("chat")
                
                Text("Settings")
                    .modifier(BGModifier())
                    .tag("settings")
            }
            
            // Custom Tab bar...
            HStack(spacing: 40) {
                // Tab buttons...
                TabButton(image: "home")
                TabButton(image: "graph")
                
                // Center Add button...
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(22)
                        .background(
                            Circle()
                                .fill(Color("Tab"))
                                .shadow(color: Color("BG").opacity(0.15), radius: 5, x: 0, y: 8)
                        )
                }
                // Moving button little up
                .offset(y: -20)
                .padding(.horizontal, -15)
                
                TabButton(image: "chat")
                TabButton(image: "settings")
            }
            .padding(.top, -10)
            .frame(maxWidth: .infinity)
            .background(Color("BG").ignoresSafeArea())
        }
    }
    
    @ViewBuilder
    func TabButton(image: String) -> some View {
        Button {
            withAnimation {
                currentTab = image
            }
        } label: {
            Image(image)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(
                    currentTab == image ? .black : .gray.opacity(0.8)
                )
        }
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        BaseView()
    }
}


// BG modifier...
struct BGModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BG").ignoresSafeArea())
    }
}
