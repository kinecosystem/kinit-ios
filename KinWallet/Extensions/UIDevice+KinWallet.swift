//
//  UIDevice+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

extension UIDevice {
    private func hardwareString() -> String {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, nil, 0)
        var hw_machine = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hw_machine, &size, nil, 0)

        let hardware: String = String(cString: hw_machine)
        return hardware
    }

    var modelMarketingName: String {
        let hardware = hardwareString()

        guard
            let listDictPath = Bundle.main.path(forResource: "DeviceList", ofType: "plist"),
            let deviceListDict = NSDictionary(contentsOfFile: listDictPath) as? [String: AnyObject],
            let hardwareDetail = deviceListDict[hardware] as? [String: AnyObject],
            let hardwareDescription = hardwareDetail["name"] as? String else {
            return hardware
        }

        return hardwareDescription
    }

    static func isiPhone5() -> Bool {
        return AppDelegate.shared.window?.bounds.height == 568
    }
}
