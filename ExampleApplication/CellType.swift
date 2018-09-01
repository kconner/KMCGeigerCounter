//
//  CellType.swift
//  ExampleApplication
//
//  Created by Kevin Conner on 9/1/18.
//  Copyright © 2018 Kevin Conner. All rights reserved.
//

enum CellType: Int {

    case cheap = 0
    case expensive = 1
    case exorbitant = 2

    var cellIdentifier: String {
        switch self {
        case .cheap:
            return "cheap"
        case .expensive:
            return "expensive"
        case .exorbitant:
            return "exorbitant"
        }
    }

}
