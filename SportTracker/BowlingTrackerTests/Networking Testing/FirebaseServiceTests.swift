import XCTest
import Combine
@testable import BowlingTracker
import FirebaseFirestore

class FirebaseServiceTests: XCTestCase {
    var mockFirestore: MockFirestore!
    var firebaseService: MockSeriesFirebaseService!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestore()
        firebaseService = MockSeriesFirebaseService(mockFirestore: mockFirestore, collectionName: CollectionNames.series)
    }

    override func tearDown() {
        mockFirestore = nil
        firebaseService = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testSaveSeries_Success() {
        let series = Series(name: "dummyName", tag: .league)

        let expectation = self.expectation(description: "Series should be saved successfully")

        firebaseService.save(series, withID: series.id)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Save should not fail: \(error)")
                }
            }, receiveValue: {
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func testFetchAllSeries_Success() {
        let series1 = Series(name: "dummyName1", tag: .league)
        let series2 = Series(name: "dummyName2", tag: .tournament)

        let series1Data = try! Firestore.Encoder().encode(series1)
        let series2Data = try! Firestore.Encoder().encode(series2)

        mockFirestore.collection(CollectionNames.series).document(series1.id).setData(series1Data, completion: nil)
        mockFirestore.collection(CollectionNames.series).document(series2.id).setData(series2Data, completion: nil)

        let expectation = self.expectation(description: "All series should be fetched")

        firebaseService.fetchAll()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Fetch should not fail: \(error)")
                }
            }, receiveValue: { seriesList in
                XCTAssertEqual(seriesList.count, 2, "Should fetch exactly 2 series")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }


    func testDeleteSeries_Success() {
        let series = Series(name: "dummyName", tag: .practise)

        mockFirestore.collection(CollectionNames.series).document(series.id).setData(try! Firestore.Encoder().encode(series), completion: nil)

        let expectation = self.expectation(description: "Series should be deleted successfully")

        firebaseService.delete(id: series.id)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Delete should not fail: \(error)")
                }
            }, receiveValue: {
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }
}
