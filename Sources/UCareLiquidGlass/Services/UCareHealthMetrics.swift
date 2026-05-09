import Foundation
import HealthKit

/// Phase 6 — read-only Apple Health: dietary water + sleep analysis for on-device Glow-Up blending.
enum UCareHealthMetricsError: Error {
    case healthDataUnavailable
    case authorizationDenied
}

struct UCareHealthWeekSnapshot: Equatable, Sendable {
    /// Calendar start-of-day → liters logged that day.
    var waterLitersByStartOfDay: [Date: Double]
    /// Calendar start-of-day → estimated asleep hours overlapping that day.
    var sleepHoursByStartOfDay: [Date: Double]
    var fetchedAt: Date
}

enum UCareHealthMetrics {
    private static let store = HKHealthStore()

    static func isDataAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    static func requestReadAuthorization() async throws {
        guard isDataAvailable() else { throw UCareHealthMetricsError.healthDataUnavailable }
        guard let water = HKObjectType.quantityType(forIdentifier: .dietaryWater),
              let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw UCareHealthMetricsError.healthDataUnavailable
        }
        try await store.requestAuthorization(toShare: [], read: [water, sleep])
    }

    /// Call after `requestReadAuthorization()` to see if the user allowed at least one read type.
    static func readAccessLikelyGranted() -> Bool {
        guard isDataAvailable(),
              let water = HKObjectType.quantityType(forIdentifier: .dietaryWater),
              let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return false }
        func authorized(_ type: HKObjectType) -> Bool {
            store.authorizationStatus(for: type) == .sharingAuthorized
        }
        return authorized(water) || authorized(sleep)
    }

    static func fetchWeekSnapshot(reference: Date = .now) async throws -> UCareHealthWeekSnapshot {
        guard isDataAvailable() else { throw UCareHealthMetricsError.healthDataUnavailable }
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw UCareHealthMetricsError.healthDataUnavailable
        }

        let wDenied = store.authorizationStatus(for: waterType) == .sharingDenied
        let sDenied = store.authorizationStatus(for: sleepType) == .sharingDenied
        if wDenied, sDenied { throw UCareHealthMetricsError.authorizationDenied }

        let cal = Calendar.current
        let day0 = cal.startOfDay(for: reference)
        let end = day0.addingTimeInterval(86_400)
        guard let rangeStart = cal.date(byAdding: .day, value: -45, to: day0) else {
            throw UCareHealthMetricsError.healthDataUnavailable
        }

        async let waterMap = queryWaterLiters(from: rangeStart, to: end, type: waterType, calendar: cal)
        async let sleepMap = querySleepHoursByDay(from: rangeStart, to: end, type: sleepType, calendar: cal)
        let (w, s) = try await (waterMap, sleepMap)
        return UCareHealthWeekSnapshot(waterLitersByStartOfDay: w, sleepHoursByStartOfDay: s, fetchedAt: .now)
    }

    private static func queryWaterLiters(
        from start: Date,
        to end: Date,
        type: HKQuantityType,
        calendar cal: Calendar
    ) async throws -> [Date: Double] {
        if store.authorizationStatus(for: type) == .sharingDenied { return [:] }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let samples: [HKQuantitySample] = try await withCheckedThrowingContinuation { cont in
            let q = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, results, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                cont.resume(returning: (results as? [HKQuantitySample]) ?? [])
            }
            store.execute(q)
        }
        let liter = HKUnit.liter()
        var byDay: [Date: Double] = [:]
        for s in samples {
            let day = cal.startOfDay(for: s.startDate)
            let L = s.quantity.doubleValue(for: liter)
            byDay[day, default: 0] += L
        }
        return byDay
    }

    private static func querySleepHoursByDay(
        from start: Date,
        to end: Date,
        type: HKCategoryType,
        calendar cal: Calendar
    ) async throws -> [Date: Double] {
        if store.authorizationStatus(for: type) == .sharingDenied { return [:] }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { cont in
            let q = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                cont.resume(returning: (results as? [HKCategorySample]) ?? [])
            }
            store.execute(q)
        }

        var dayStarts: [Date] = []
        var cursor = cal.startOfDay(for: start)
        let last = cal.startOfDay(for: end)
        while cursor <= last {
            dayStarts.append(cursor)
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }

        var hoursByDay: [Date: Double] = [:]
        for day in dayStarts {
            guard let dayEnd = cal.date(byAdding: .day, value: 1, to: day) else { continue }
            var sec: TimeInterval = 0
            for s in samples where isAsleepSample(s) {
                sec += overlapSeconds(sampleStart: s.startDate, sampleEnd: s.endDate, windowStart: day, windowEnd: dayEnd)
            }
            let h = sec / 3600
            if h > 0.02 {
                hoursByDay[day] = h
            }
        }
        return hoursByDay
    }

    private static func isAsleepSample(_ sample: HKCategorySample) -> Bool {
        guard let v = HKCategoryValueSleepAnalysis(rawValue: sample.value) else { return false }
        switch v {
        case .asleepUnspecified, .asleepCore, .asleepDeep, .asleepREM:
            return true
        default:
            return false
        }
    }

    private static func overlapSeconds(sampleStart: Date, sampleEnd: Date, windowStart: Date, windowEnd: Date) -> TimeInterval {
        let s = max(sampleStart, windowStart)
        let e = min(sampleEnd, windowEnd)
        return max(0, e.timeIntervalSince(s))
    }
}
