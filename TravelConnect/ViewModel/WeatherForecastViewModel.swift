//
//  WeatherForecastViewModel.swift
//  TravelConnect
//
//  Created by Cube on 10/29/23.
//

import Foundation
import Combine

struct Constants {
    //static let RAPIDAPIKEY = "620035982dmshfefc0b106524436p1ef359jsn8f2cb31aa928"
   // static let RAPIDAPIHOST = "weatherapi-com.p.rapidapi.com"
}

class WeatherForecastViewModel: ObservableObject {
    @Published var forecastLocation: ForecastLocation?
    @Published var forecasts: [Forecast] = []

    private var cancellables: Set<AnyCancellable> = []

    func getWeatherForecastData(city: String) {
        getWeatherForecastData(city: city)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error retrieving weather data: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func getWeatherForecastData(city: String) -> AnyPublisher<Void, Error> {

        let headers = [
            "X-RapidAPI-Key": "",//Constants.RAPIDAPIKEY,
            "X-RapidAPI-Host": ""//Constants.RAPIDAPIHOST
        ]
        
        let safeCityString = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        
        guard let url = URL(string: "https://weatherapi-com.p.rapidapi.com/forecast.json?q=\(safeCityString)&days=3") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ForecastAPIModel.self, decoder: JSONDecoder())
            .map { apiData -> Void in
                let locationModel = ForecastLocation(name: apiData.location.name,
                                                     region: apiData.location.region,
                                                     country: apiData.location.country,
                                                     lat: apiData.location.lat,
                                                     lon: apiData.location.lon)
                let forecasts: [Forecast] = apiData.forecast.forecastday.compactMap { dayForecast -> Forecast? in
                    guard let date = self.dateFormatter.date(from: dayForecast.date) else {
                        print("Invalid date format in the API response for \(dayForecast.date)")
                        return nil
                    }
                    return Forecast(id: UUID(),
                                    date: date,
                                    maxtemp_c: dayForecast.day.maxtemp_c,
                                    mintemp_c: dayForecast.day.mintemp_c,
                                    conditionText: dayForecast.day.condition.text)
                }
                
                // Update the properties
                self.forecastLocation = locationModel
                self.forecasts = forecasts
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust this to match the date format returned by the API
        return formatter
    }()
}
