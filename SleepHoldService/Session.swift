//
//  Session.swift
//  SleepHoldService
//
//  Created by 秋星桥 on 5/24/25.
//

import Foundation

class SessionManager {
    static let shared = SessionManager()

    private var sessions: [String: Date] = [:]
    private let sessionDuration: TimeInterval = 30.0 // 30 seconds
    private var timer: Timer?
    private let lock = NSLock()

    private init() {
        startCleanupTimer()
    }

    func createSession() -> String {
        lock.lock()
        defer { lock.unlock() }

        let sessionId = UUID().uuidString
        let expirationTime = Date().addingTimeInterval(sessionDuration)
        sessions[sessionId] = expirationTime
        updateSleepState()
        return sessionId
    }

    func extendSession(_ sessionId: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard sessions[sessionId] != nil else {
            return false
        }
        let expirationTime = Date().addingTimeInterval(sessionDuration)
        sessions[sessionId] = expirationTime
        updateSleepState()
        return true
    }

    func terminateSession(_ sessionId: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard sessions.removeValue(forKey: sessionId) != nil else {
            return false
        }
        updateSleepState()
        return true
    }

    private func startCleanupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.cleanupExpiredSessions()
        }
    }

    private func cleanupExpiredSessions() {
        lock.lock()
        defer { lock.unlock() }

        let now = Date()
        let expiredSessions = sessions.filter { $0.value < now }

        for (sessionId, _) in expiredSessions {
            sessions.removeValue(forKey: sessionId)
        }

        if !expiredSessions.isEmpty {
            updateSleepState()
        }
    }

    private func updateSleepState() {
        let hasActiveSessions = !sessions.isEmpty
        let targetState: IOPower.SleepValue = hasActiveSessions ? .hold : .canSleep

        if IOPower.read() != targetState {
            _ = IOPower.set(targetState)
        }
    }

    func getActiveSessionsCount() -> Int {
        sessions.count
    }
}
