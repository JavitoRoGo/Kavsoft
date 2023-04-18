//
//  Graph.swift
//  Graph
//
//  Created by Javier Rodríguez Gómez on 31/1/23.
//

import WidgetKit
import SwiftUI

// First creating model for widget data

struct Model: TimelineEntry {
    var date: Date
    var widgetData: [JSONModel]
}

// Creating model for json data

struct JSONModel: Decodable, Hashable {
    var date: CGFloat
    var units: Int
}

// Creating provider for providing data for widget

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Model {
        Model(date: Date(), widgetData: Array(repeating: JSONModel(date: 0, units: 0), count: 6))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Model) -> Void) {
        // Initial snapshot or loading type content
        let loadingData = Model(date: Date(), widgetData: Array(repeating: JSONModel(date: 0, units: 0), count: 6))
        completion(loadingData)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Model>) -> Void) {
        // Parsing json data and displaying
        getData { modelData in
            let date = Date()
            let data = Model(date: date, widgetData: modelData)
            
            // Creating timeline
            // Reloading data every 15 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: date)
            let timeline = Timeline(entries: [data], policy: .after(nextUpdate!))
            completion(timeline)
        }
    }
}

// Creating view for widget

struct WidgetView: View {
    var data: Model
    let colors: [Color] = [.red, .yellow, .red, .blue, .green, .pink, .purple]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Displaying date of update
            
            HStack(spacing: 15) {
                Text("Units sold")
                    .font(.title.bold())
                Text(Date(), style: .time)
                    .font(.caption2)
            }
            HStack(spacing: 15) {
                ForEach(data.widgetData, id: \.self) { value in
                    if value.units == 0 && value.date == 0 {
                        // Data is loading
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.gray)
                    } else {
                        // Data view
                        VStack(spacing: 15) {
                            Text("\(value.units)")
                                .bold()
                            // Graph
                            GeometryReader { geo in
                                VStack {
                                    Spacer(minLength: 0)
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(colors.randomElement()!)
                                    // Calculating height
                                        .frame(height: getHeight(value: CGFloat(value.units), height: geo.frame(in: .global).height))
                                }
                            }
                            Text(getData(value: value.date))
                                .font(.caption2)
                        }
                    }
                }
            }
        }
    }
    
    func getHeight(value: CGFloat, height: CGFloat) -> CGFloat {
        // Some basic calculations
        let max = data.widgetData.max { (first, second) -> Bool in
            if first.units > second.units { return false }
            else { return true }
        }
        let percent = value / CGFloat(max!.units)
        return percent * height
    }
    
    func getData(value: CGFloat) -> String {
        let format = DateFormatter()
        format.dateFormat = "MM dd"
        // Since its in milliseconds
        let date = Date(timeIntervalSince1970: value / 1000)
        return format.string(from: date)
    }
}

// Widget configuration

struct MainWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Graph", provider: Provider()) { data in
            WidgetView(data: data)
        }
        .configurationDisplayName(Text("Daily updates"))
        .description(Text("Daily status"))
        .supportedFamilies([.systemLarge])
    }
}   

// Attaching completion handler to send back data
func getData(completion: @escaping ([JSONModel]) -> ()) {
    let url = "https://canvasjs.com/data/gallery/javascript/daily-sales-data.json"
    
    let session = URLSession(configuration: .default)
    session.dataTask(with: URL(string: url)!) { data, _, err in
        if err != nil {
            print(err!.localizedDescription)
            return
        }
        do {
            let jsonData = try JSONDecoder().decode([JSONModel].self, from: data!)
            completion(jsonData)
        } catch {
            print(error.localizedDescription)
        }
    }.resume()
}
