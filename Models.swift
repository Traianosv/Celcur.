import SwiftUI

// --- Configuration ---
struct BrandConfig {
    static let appName = "Celcur."
    static let primaryColor = Color.blue
    static let supportEmail = "support@celcur.com"
    static let currencySymbol = "$"
}

// --- Models ---
struct Country: Identifiable, Hashable {
    let id: String
    let name: String
    let flag: String
    let region: String
    let network: String
    let nomadPrice: Double
}

struct Plan: Identifiable, Hashable {
    let id: String
    let data: String
    let days: Int
    let price: Double
}

struct PurchasedPlan: Identifiable {
    let id = UUID()
    let plan: Plan
    let country: Country
    var status: PlanStatus
    let date = Date()
    let iccid = "890000000000" + String(Int.random(in: 1000000000...9999999999))
}

enum PlanStatus: String {
    case notInstalled = "Not Installed"
    case active = "Active"
    case expired = "Expired"
}

// --- Extra Models ---
struct User {
    let id: String
    let name: String
    let email: String
}

// --- Data ---
let countriesDB: [Country] = [
    // Americas
    Country(id: "us", name: "United States", flag: "🇺🇸", region: "Americas", network: "AT&T / T-Mobile", nomadPrice: 59.00),
    Country(id: "ca", name: "Canada", flag: "🇨🇦", region: "Americas", network: "Rogers / Bell", nomadPrice: 55.00),
    Country(id: "mx", name: "Mexico", flag: "🇲🇽", region: "Americas", network: "Telcel", nomadPrice: 45.00),
    Country(id: "br", name: "Brazil", flag: "🇧🇷", region: "Americas", network: "Vivo", nomadPrice: 40.00),
    
    // Europe
    Country(id: "eu", name: "Europe Regional", flag: "🇪🇺", region: "Europe", network: "Multi-Network", nomadPrice: 49.00),
    Country(id: "gb", name: "United Kingdom", flag: "🇬🇧", region: "Europe", network: "Vodafone / O2", nomadPrice: 35.00),
    Country(id: "fr", name: "France", flag: "🇫🇷", region: "Europe", network: "Orange", nomadPrice: 35.00),
    Country(id: "de", name: "Germany", flag: "🇩🇪", region: "Europe", network: "Telekom", nomadPrice: 38.00),
    Country(id: "tr", name: "Turkey", flag: "🇹🇷", region: "Europe", network: "Turkcell", nomadPrice: 28.00),
    
    // Asia
    Country(id: "jp", name: "Japan", flag: "🇯🇵", region: "Asia", network: "Softbank", nomadPrice: 45.00),
    Country(id: "th", name: "Thailand", flag: "🇹🇭", region: "Asia", network: "AIS", nomadPrice: 25.00),
    Country(id: "vn", name: "Vietnam", flag: "🇻🇳", region: "Asia", network: "Viettel", nomadPrice: 22.00),
    Country(id: "kr", name: "South Korea", flag: "🇰🇷", region: "Asia", network: "SK Telecom", nomadPrice: 42.00),
    
    // Oceania
    Country(id: "au", name: "Australia", flag: "🇦🇺", region: "Oceania", network: "Telstra", nomadPrice: 50.00),
    Country(id: "nz", name: "New Zealand", flag: "🇳🇿", region: "Oceania", network: "Spark", nomadPrice: 48.00),
    
    // Middle East
    Country(id: "ae", name: "UAE", flag: "🇦🇪", region: "Middle East", network: "Etisalat", nomadPrice: 55.00),
    Country(id: "sa", name: "Saudi Arabia", flag: "🇸🇦", region: "Middle East", network: "STC", nomadPrice: 52.00),
    
    // Africa
    Country(id: "za", name: "South Africa", flag: "🇿🇦", region: "Africa", network: "Vodacom", nomadPrice: 40.00),
    Country(id: "eg", name: "Egypt", flag: "🇪🇬", region: "Africa", network: "Vodafone", nomadPrice: 35.00)
]

let standardPlans: [Plan] = [
    Plan(id: "1", data: "1 GB", days: 7, price: 4.50),
    Plan(id: "3", data: "3 GB", days: 30, price: 11.00),
    Plan(id: "5", data: "5 GB", days: 30, price: 16.00),
    Plan(id: "10", data: "10 GB", days: 30, price: 26.00)
]
