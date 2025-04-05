import Foundation

enum BowlingStyle: String, Codable {
    case twoHanded, oneHanded
    
    var description: String{
        switch self {
        case .twoHanded:
            return "Two handed"
        case .oneHanded:
            return "One handed"
        }
    }
}

enum HandStyle: String, Codable {
    case lefty, righty
    
    var description: String{
        switch self {
        case .lefty:
            return "Lefty"
        case .righty:
            return "Righty"
        }
    }
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var series: [Series]
    
    var name: String?
    var homeCenter: String?
    var style: BowlingStyle?
    var hand: HandStyle?
    var balls: [Ball]?
    
    init(
        id: String,
        email: String,
        series: [Series] = [],
        name: String? = nil,
        homeCenter: String? = nil,
        style: BowlingStyle? = nil,
        hand: HandStyle? = nil,
        balls: [Ball]? = nil
    ) {
        self.id = id
        self.email = email
        self.series = series
        self.name = name
        self.homeCenter = homeCenter
        self.style = style
        self.hand = hand
        self.balls = balls
    }
    
    /// Updates a series in the user's series array
    /// - Parameter updatedSeries: The new series data to replace the existing series
    /// - Returns: A new User instance with the updated series array
    func updateSeries(_ updatedSeries: Series) -> User {
        var updatedSeriesArray = series
        if let index = updatedSeriesArray.firstIndex(where: { $0.id == updatedSeries.id }) {
            updatedSeriesArray[index] = updatedSeries
        } else {
            updatedSeriesArray.append(updatedSeries)
        }
        return User(
            id: id,
            email: email,
            series: updatedSeriesArray,
            name: name,
            homeCenter: homeCenter,
            style:style,
            hand: hand,
            balls: balls
        )
    }
    
    /// Updates a series in the user's series array by appending a new game
    /// - Parameters:
    ///   - seriesId: The ID of the series to update
    ///   - game: The new game to append to the series
    /// - Returns: A new User instance with the updated series array
    func appendGameToSeries(seriesId: String, game: Game) -> User {
        var updatedSeriesArray = series
        if let index = updatedSeriesArray.firstIndex(where: { $0.id == seriesId }) {
            var updatedSeries = updatedSeriesArray[index]
            updatedSeries.games.append(game)
            updatedSeriesArray[index] = updatedSeries
        }
        return User(
            id: id,
            email: email,
            series: updatedSeriesArray,
            name: name,
            homeCenter: homeCenter,
            style:style,
            hand: hand,
            balls: balls
        )
    }
}
