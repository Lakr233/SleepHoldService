//
//  IOPower.swift
//  SleepHoldService
//
//  Created by 秋星桥 on 5/24/25.
//

import Foundation

enum IOPower {
    enum SleepValue: String, RawRepresentable, Codable {
        case canSleep = "sleep_enabled"
        case hold = "sleep_disabled"
        case unknown
    }

    typealias F_IOPMSetSystemPowerSetting = @convention(c) (CFString, CFTypeRef) -> IOReturn

    static let IOPMSetSystemPowerSetting: F_IOPMSetSystemPowerSetting = {
        let handler = dlopen("/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit", RTLD_NOW)
        if handler == nil { fatalError("Failed to load IOKit framework") }
        let fn = dlsym(handler, "IOPMSetSystemPowerSetting")
        if fn == nil { fatalError("Failed to load IOPMSetSystemPowerSetting function") }
        return unsafeBitCast(fn, to: F_IOPMSetSystemPowerSetting.self)
    }()

    static func read() -> SleepValue {
        let entry = IORegistryEntryFromPath(kIOMainPortDefault, "IOPower:/IOPowerConnection/IOPMrootDomain")
        defer { IOObjectRelease(entry) }

        let property = "SleepDisabled"
        var sleepDisabled = false

        let ret = property.withCString { bytes in
            var valueSize = UInt32(MemoryLayout<CFBoolean>.size)
            return IORegistryEntryGetProperty(
                entry,
                bytes,
                &sleepDisabled,
                &valueSize
            )
        }
        if ret == KERN_SUCCESS {
            return sleepDisabled ? .hold : .canSleep
        }
        return .unknown
    }

    static func set(_ status: SleepValue) -> Result<Void, Error> {
        let ret = switch status {
        case .canSleep:
            IOPMSetSystemPowerSetting("SleepDisabled" as CFString, kCFBooleanFalse)
        case .hold:
            IOPMSetSystemPowerSetting("SleepDisabled" as CFString, kCFBooleanTrue)
        case .unknown: preconditionFailure("you are not allowed to set unknown power status")
        }

        if ret == kIOReturnSuccess {
            return .success(())
        } else {
            return .failure(NSError(domain: "IOPMSetSystemPowerSetting", code: .init(ret)))
        }
    }
}
