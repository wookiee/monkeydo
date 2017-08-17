//
//  Result.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/4/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Foundation

extension String : Error {}

enum Result<Content> {
    case success(Content)
    case failure(Error)
}

enum BooleanResult: Equatable {
    case success
    case failure(Error)
    
    static func ==(left: BooleanResult, right: BooleanResult) -> Bool {
        switch (left, right) {
        case (.success, .success):
            return true
        case (.success, _), (_, .success):
            return false
        case (.failure(let fl), .failure(let fr)):
            return fl.localizedDescription == fr.localizedDescription
        }
    }
}
