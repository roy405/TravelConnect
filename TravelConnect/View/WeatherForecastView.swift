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
                ForEach(viewModel.forecasts, id: \.date) { forecast in  // Using viewModel's forecasts array
                    DayWeatherView(forecast: forecast)
                }
            }
        }
        .onAppear {
            viewModel.getWeather(city: city)
        }
    }
}


struct DayWeatherView: View {
    var forecast: Forecast

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(dateString(from: forecast.date))
                .font(.title)
            Text("\(forecast.maxtemp_c, specifier: "%.1f")°C / \(forecast.mintemp_c, specifier: "%.1f")°C")
                .font(.title3)
            Text(forecast.conditionText)
                .font(.title2)
        }
        .foregroundColor(.white)
        .frame(width: 200,height: 200)
        .background(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
        .padding()
    }

    func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"  // Full name of the day
        return formatter.string(from: date)
    }
}

