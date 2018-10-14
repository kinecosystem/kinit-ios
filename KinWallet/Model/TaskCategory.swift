//
//  TaskCategory.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation
import UIKit

//swiftlint:disable type_name
//swiftlint:disable nesting

struct TaskCategory: Codable {
    struct UI: Codable {
        let hexColor: String
        let headerImageURL: URL
        let iconImageURL: URL

        enum CodingKeys: String, CodingKey {
            case hexColor = "color"
            case headerImageURL = "header_image_url"
            case iconImageURL = "image_url"
        }
    }

    let identifier: String
    let availableTasksCount: Int
    let title: String
    let ui: UI

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case availableTasksCount = "available_tasks_count"
        case title
        case ui = "ui_data"
    }
}

//swiftlint:enable type_name
//swiftlint:enable nesting

extension TaskCategory.UI {
    var color: UIColor? {
        return UIColor(hexString: hexColor)
    }
}
