//
//  main.swift
//  SleepHoldService
//
//  Created by 秋星桥 on 5/24/25.
//

import Foundation
import Vapor
import Darwin

// SleepHoldService serve --hostname 127.0.0.1 -p 8180

precondition(getuid() == 0, "SleepHoldService ")
_ = SessionManager.shared

let app = try await Application.make(.detect())

app.get("ping") { _ in
    HTTPStatus.ok
}

app.get(["service", "status"]) { _ in
    let s = IOPower.get()
    return ["status": s.rawValue]
}

app.post(["service", "session", "create"]) { _ in
    let sessionId = SessionManager.shared.createSession()
    return ["sessionId": sessionId]
}

app.post(["service", "session", "extend"]) { req in
    struct ExtendRequest: Content {
        let sessionId: String
    }
    
    let request = try req.content.decode(ExtendRequest.self)
    let success = SessionManager.shared.extendSession(request.sessionId)
    
    if success {
        return HTTPStatus.ok
    } else {
        throw Abort(.notFound, reason: "Session not found")
    }
}

app.post(["service", "session", "terminate"]) { req in
    struct TerminateRequest: Content {
        let sessionId: String
    }
    
    let request = try req.content.decode(TerminateRequest.self)
    let success = SessionManager.shared.terminateSession(request.sessionId)
    
    if success {
        return HTTPStatus.ok
    } else {
        throw Abort(.notFound, reason: "Session not found")
    }
}

try await app.execute()
