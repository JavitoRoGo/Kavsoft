//
//  Home.swift
//  LineChart
//
//  Created by Javier Rodríguez Gómez on 18/4/22.
//

import SwiftUI

struct Home: View {
    var body: some View {
        VStack {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "slider.vertical.3")
                        .font(.title2)
                }
                Spacer()
                Button {
                    
                } label: {
                    Image("ijustine")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                }
            }
            .padding()
            .foregroundColor(.black)
            
            VStack(spacing: 10) {
                Text("Total Balance")
                    .bold()
                Text("$ 51 200")
                    .font(.system(size: 38, weight: .bold))
            }
            .padding(.top, 20)
            
            Button {
                
            } label: {
                HStack(spacing: 5) {
                    Text("Income")
                    Image(systemName: "chevron.down")
                }
                .font(.caption.bold())
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(.white, in: Capsule())
                .foregroundColor(.black)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 5, y: 5)
                .shadow(color: .black.opacity(0.03), radius: 5, x: -5, y: -5)
            }
            
            // Graph view...
            LineGraph(data: samplePlot)
            // Max size...
                .frame(height: 220)
                .padding(.top, 25)
            
            Text("Shorcuts")
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.gray.opacity(0.2))
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}


// Sample Plot for graph...
let samplePlot: [CGFloat] = [
    989,1200,750,790,650,950,1200,600,500,600,890,1203,1400,900,1250,1600,1200
]
