import XCTest
import Nimble

class HaveCountTest: XCTestCase {
    func testHaveCountForArray() {
        expect([1, 2, 3]).to(haveCount(3))
        expect([1, 2, 3]).notTo(haveCount(1))

        failsWithErrorMessage("expected to have [1, 2, 3] with count 1, got 3") {
            expect([1, 2, 3]).to(haveCount(1))
        }

        failsWithErrorMessage("expected to not have [1, 2, 3] with count 3, got 3") {
            expect([1, 2, 3]).notTo(haveCount(3))
        }
    }

    func testHaveCountForDictionary() {
        expect(["1":1, "2":2, "3":3]).to(haveCount(3))
        expect(["1":1, "2":2, "3":3]).notTo(haveCount(1))

        failsWithErrorMessage("expected to have [\"2\": 2, \"1\": 1, \"3\": 3] with count 1, got 3") {
            expect(["1":1, "2":2, "3":3]).to(haveCount(1))
        }

        failsWithErrorMessage("expected to not have [\"2\": 2, \"1\": 1, \"3\": 3] with count 3, got 3") {
            expect(["1":1, "2":2, "3":3]).notTo(haveCount(3))
        }
    }

    func testHaveCountForSet() {
        expect(Set([1, 2, 3])).to(haveCount(3))
        expect(Set([1, 2, 3])).notTo(haveCount(1))

        failsWithErrorMessage("expected to have [2, 3, 1] with count 1, got 3") {
            expect(Set([1, 2, 3])).to(haveCount(1))
        }

        failsWithErrorMessage("expected to not have [2, 3, 1] with count 3, got 3") {
            expect(Set([1, 2, 3])).notTo(haveCount(3))
        }
    }
}
