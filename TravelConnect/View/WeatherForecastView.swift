//
//  WeatherForecastView.swift
//  TravelConnect
//
//  Created by Cube on 10/29/23.
//

import SwiftUI
import Combine

struct WeatherForecastView: View {
    @StateObject var viewModel = WeatherForecastViewModel()
    var city: String
    
    @State var dummyForecasts: [Forecast] = [
        Forecast(id: UUID(), date: Date(), maxtemp_c: 23.5, mintemp_c: 15.2, conditionText: "Sunny"),
        Forecast(id: UUID(), date: Date().addingTimeInterval(86400), maxtemp_c: 25.0, mintemp_c: 17.3, conditionText: "Cloudy"),
        Forecast(id: UUID(), date: Date().addingTimeInterval(172800), maxtemp_c: 20.4, mintemp_c: 14.0, conditionText: "Rainy")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(dummyForecasts, id: \.date) { forecast in
                    DayWeatherView(forecast: forecast)
                }
            }
        }
        // Comment out the following line to prevent fetching data
        // .onAppear {
        //    viewModel.getWeatherForecastData(city: city)
        // }
    }
}


struct DayWeatherView: View {
    var forecast: Forecast

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dateString(from: forecast.date)).foregroundColor(.white)
            Text("\(forecast.maxtemp_c, specifier: "%.1f")°C / \(forecast.mintemp_c, specifier: "%.1f")°C").foregroundColor(.white)
            Text(forecast.conditionText).foregroundColor(.white)
        }
        .padding()
        .frame(width: 200)
        .background(Color.blue)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
    }

    func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"  // Full name of the day
        return formatter.string(from: date)
    }
}

