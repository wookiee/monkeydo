//
//  Zip+3.swift
//  MonkeyDo
//
//  Created by Michael L. Ward on 2/5/18.
//  Copyright © 2018 Mikey Ward. All rights reserved.
//

// from https://gist.github.com/wookiee/6c50522a29a58c07c95b2d0d2fa58458
// forked from https://gist.github.com/JRHeaton/ff5addcd72f221dd57ad

import Foundation

struct Zip3Iterator
<
    A: IteratorProtocol,
    B: IteratorProtocol,
    C: IteratorProtocol
>: IteratorProtocol {
    
    private var first: A
    private var second: B
    private var third: C
    
    private var index = 0
    
    init(_ first: A, _ second: B, _ third: C) {
        self.first = first
        self.second = second
        self.third = third
    }
    
    mutating func next() -> (A.Element, B.Element, C.Element)? {
        if let a = first.next(), let b = second.next(), let c = third.next() {
            return (a, b, c)
        }
        return nil
    }
}

func zip<A: Sequence, B: Sequence, C: Sequence>(a: A, b: B, c: C) -> IteratorSequence<Zip3Iterator<A.Iterator, B.Iterator, C.Iterator>> {
    return IteratorSequence(Zip3Iterator(a.makeIterator(), b.makeIterator(), c.makeIterator()))
}
