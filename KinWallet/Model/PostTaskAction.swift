//
//  PostTaskAction.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

enum PostTaskActionType: String, Codable {
    case externalURL = "external-url"
}

struct PostTaskAction: Codable {
    let type: PostTaskActionType
    let title: String
    let message: String
    let url: URL?
    let textPositive: String
    let textNegative: String
    let actionName: String
    let iconURL: URL?

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case message = "text"
        case url
        case textPositive = "text_positive"
        case textNegative = "text_negative"
        case actionName = "action_name"
        case iconURL = "icon_url"
    }
}
