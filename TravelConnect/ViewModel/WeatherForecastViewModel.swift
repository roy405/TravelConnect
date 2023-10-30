//
//  WeatherForecastViewModel.swift
//  TravelConnect
//
//  Created by Cube on 10/29/23.
//

import Foundation
import Combine

// Constants containing the API Key and Host for Weather.com API via RAPIDAPI
struct Constants {
    //static let RAPIDAPIKEY = "620035982dmshfefc0b106524436p1ef359jsn8f2cb31aa928"
    //static let RAPIDAPIHOST = "weatherapi-com.p.rapidapi.com"
}

// Viewmodel for handling weather forecast
class WeatherForecastViewModel: ObservableObject {
    // Obserables variables for forecast location and forecast data
    @Published var forecastLocation: ForecastLocation?
    @Published var forecasts: [Forecast] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    /// Fetches the weather forecast data for a given city and updates the view model's properties.
    /// - Parameter city: The city for which the weather data is required.
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
    
    /// Makes a call to the RAPID API for weather forecast data.
    /// - Parameter city: The city for which the weather data is required.
    /// - Returns: A publisher that emits either the fetched data or an error.
    func getWeatherForecastData(city: String) -> AnyPublisher<Void, Error> {
        
        // Setting headers for RAPID API using the constants for authentication
        let headers = [
            "X-RapidAPI-Key": "",//Constants.RAPIDAPIKEY,
            "X-RapidAPI-Host": ""//Constants.RAPIDAPIHOST
        ]
        // Encode city string to ensure it's safe for URL use
        let safeCityString = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        
        guard let url = URL(string: "https://weatherapi-com.p.rapidapi.com/forecast.json?q=\(safeCityString)&days=3") else {
            // return a URL error if the URL could not be constructed
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error -> Error in
                // Convert any URLSession errors to a more generic error type if needed
                return error
            }
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
                
                // Update the view model's properties
                self.forecastLocation = locationModel
                self.forecasts = forecasts
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Date formatter for required date format
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
