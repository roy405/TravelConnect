//
//  Interests.swift
//  TravelConnect
//
//  Created by Cube on 10/29/23.
//

import Foundation

// Represents a categorized list of interests.
struct Interests: Decodable {
    let natureAndOutdoors: [String]
    let culturalAndHistorical: [String]
    let relaxation: [String]
    let urbanAndModern: [String]
    let adventurousAndExtreme: [String]
    let recreationalAndSports: [String]
    let educational: [String]
    let ecoAndResponsible: [String]
    let luxuryAndExclusive: [String]
    let nicheAndSpecific: [String]
    let familyAndGroup: [String]
    
    // Coding keys for decoding the JSON keys into Swift variable names.
    enum CodingKeys: String, CodingKey {
        case natureAndOutdoors = "Nature & Outdoors"
        case culturalAndHistorical = "Cultural & Historical"
        case relaxation = "Relaxation"
        case urbanAndModern = "Urban & Modern"
        case adventurousAndExtreme = "Adventurous & Extreme"
        case recreationalAndSports = "Recreational & Sports"
        case educational = "Educational"
        case ecoAndResponsible = "Eco & Responsible"
        case luxuryAndExclusive = "Luxury & Exclusive"
        case nicheAndSpecific = "Niche & Specific"
        case familyAndGroup = "Family & Group"
    }
}
