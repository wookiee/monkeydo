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

enum BooleanResult {
    case success
    case failure(Error)
}
