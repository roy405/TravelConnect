//
//  ForecastAPIModel.swift
//  TravelConnect
//
//  Created by Cube on 10/29/23.
//

import Foundation

// Represents the weather forecast model received from an API.
struct ForecastAPIModel: Codable {
    let location: Location
    let forecast: ForecastDays

    // Represents the location details for the forecast.
    struct Location: Codable {
        let name: String
        let region: String
        let country: String
        let lat: Double
        let lon: Double
    }

    // Represents a collection of forecasted days.
    struct ForecastDays: Codable {
        let forecastday: [DayForecast]
    }
    
    // Represents the details for each forecasted day.
    struct DayForecast: Codable {
        let date: String
        let day: DayDetails

        // Detailed weather data for the day.
        struct DayDetails: Codable {
            let maxtemp_c: Double
            let mintemp_c: Double
            let condition: Condition

            // Represents the general weather condition for the day.
            struct Condition: Codable {
                let text: String
            }
        }
    }
}
