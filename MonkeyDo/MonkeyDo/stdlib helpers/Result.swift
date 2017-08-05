//
//  Result.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 8/4/17.
//  Copyright © 2017 Mikey Ward. All rights reserved.
//

import Foundation

enum Result<Content> {
    case success(Content)
    case failure(Error)
}

