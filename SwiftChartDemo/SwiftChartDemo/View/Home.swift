//
//  Home.swift
//  SwiftChartDemo
//
//  Created by Javier Rodríguez Gómez on 5/10/22.
//

import Charts
import SwiftUI

struct Home: View {
    // MARK: State chart data for animation changes
    @State var sampleAnalytics: [SiteView] = sample_analytics
    // MARK: View properties
    @State var currentTab: String = "7 Days"
    // MARK: Gesture properties
    @State var currentActiveItem: SiteView?
    @State var plotWidth: CGFloat = 0
    
    @State var isLineGraph: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Views")
                            .fontWeight(.semibold)
                        Picker("", selection: $currentTab) {
                            Text("7 Days")
                                .tag("7 Days")
                            Text("Week")
                                .tag("Week")
                            Text("Month")
                                .tag("Month")
                        }
                        .pickerStyle(.segmented)
                        .padding(.leading, 80)
                    }
                    
                    let totalValue = sampleAnalytics.reduce(0.0) { partialResult, item in
                        item.views + partialResult
                    }
                    
                    Text(totalValue.stringFormat)
                        .font(.largeTitle.bold())
                    
                    AnimatedChart()
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.shadow(.drop(radius: 2)))
                }
                
                Toggle("Line Graph", isOn: $isLineGraph)
                    .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle("Swift Charts")
            // MARK: Simply updating values for segmented tabs
            // Lo que hace es darle valores aleatorios al cambiar el picker
            .onChange(of: currentTab) { newValue in
                sampleAnalytics = sample_analytics
                if newValue != "7 Days" {
                    for (index, _) in sampleAnalytics.enumerated() {
                        sampleAnalytics[index].views = .random(in: 1500...10000)
                    }
                }
                // Re-animating view
                animateGraph(fromChange: true)
            }
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        let max = sampleAnalytics.max { item1, item2 in
            return item2.views > item1.views
        }?.views ?? 0
        
        Chart {
            ForEach(sampleAnalytics) { item in
                if isLineGraph {
                    LineMark(
                        x: .value("Hour", item.hour, unit: .hour),
                        // MARK: Animating graph
                        y: .value("Views", item.animate ? item.views : 0)
                    )
                    // Applying gradient style
                    // From SwiftUI 4.0 we can directly create gradient from color
                    .foregroundStyle(Color("Blue").gradient)
                    .interpolationMethod(.catmullRom)
                    AreaMark(
                        x: .value("Hour", item.hour, unit: .hour),
                        // MARK: Animating graph
                        y: .value("Views", item.animate ? item.views : 0)
                    )
                    // Applying gradient style
                    // From SwiftUI 4.0 we can directly create gradient from color
                    .foregroundStyle(Color("Blue").opacity(0.1).gradient)
                    .interpolationMethod(.catmullRom)
                } else {
                    BarMark(
                        x: .value("Hour", item.hour, unit: .hour),
                        // MARK: Animating graph
                        y: .value("Views", item.animate ? item.views : 0)
                    )
                    // Applying gradient style
                    // From SwiftUI 4.0 we can directly create gradient from color
                    .foregroundStyle(Color("Blue").gradient)
                }
                
                
                
                // MARK: Rule mark for currenly dragging item
                if let currentActiveItem,currentActiveItem.id == item.id {
                    RuleMark(x: .value("Hour", currentActiveItem.hour))
                    // Dotted style
                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2],dashPhase: 5))
                    // MARK: Setting in middle of each bars
                        .offset(x: (plotWidth / CGFloat(sampleAnalytics.count)) / 2)
                        .annotation(position: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Views")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(currentActiveItem.views.stringFormat)
                                    .font(.title3.bold())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }
                        }
                }
            }
        }
        // MARK: Customizing Y-axis length
        .chartYScale(domain: 0...(max + 5100))
        // MARK: Gesture to highlight current bar
        .chartOverlay(content: { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // MARK: Getting current location
                                let location = value.location
                                // Extracting value from the location
                                // Swift Charts gives the direct ability to do that
                                // We're going to extract the Date in A-axis then with the help of that Date value we're extracting the current item
                                if let date: Date = proxy.value(atX: location.x) {
                                    // Extracting hour
                                    let calendar = Calendar.current
                                    let hour = calendar.component(.hour, from: date)
                                    if let currentItem = sampleAnalytics.first(where: { item in
                                        calendar.component(.hour, from: item.hour) == hour }) {
                                        self.currentActiveItem = currentItem
                                        self.plotWidth = proxy.plotAreaSize.width
                                    }
                                }
                            }.onEnded { value in
                                self.currentActiveItem = nil
                            }
                    )
            }
        })
        .frame(height: 250)
        .onAppear {
            animateGraph()
        }
    }
    
    // MARK: Animating graph
    func animateGraph(fromChange: Bool = false) {
        for (index, _) in sampleAnalytics.enumerated() {
            // For some reason Delay is not working. So, using dispatch queue delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
                withAnimation(fromChange ? .easeInOut(duration: 0.8) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)) {
                    sampleAnalytics[index].animate = true
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}


// MARK: Extension to convert double to string with K,M number values
extension Double {
    var stringFormat: String {
        if self >= 10000 && self < 999999 {
            return String(format: "%.1fK", self / 1000).replacingOccurrences(of: ".0", with: "")
        }
        if self > 999999 {
            return String(format: "%.1fM", self / 1000000).replacingOccurrences(of: ".0", with: "")
        }
        return String(format: "%.0f", self)
    }
}
