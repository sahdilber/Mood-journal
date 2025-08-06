//
//  Item.swift
//  MoodJournal
//
//  Created by Dilber Şah on 28.07.2025.
//

import Foundation
import SwiftData

// SwiftData ile kullanılan örnek veri modeli (gerekiyorsa ileride silinebilir)
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

