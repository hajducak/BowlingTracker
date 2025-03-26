import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var series: [Series]
    
    init(id: String, email: String, series: [Series] = []) {
        self.id = id
        self.email = email
        self.series = series
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
        return User(id: id, email: email, series: updatedSeriesArray)
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
        return User(id: id, email: email, series: updatedSeriesArray)
    }
} 