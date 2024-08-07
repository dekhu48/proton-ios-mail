//
//  Key+Extensions.swift
//  ProtonCore-DataModel - Created on 4/19/21.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

extension Array where Element: Key {
    func archive() -> Data {
        // This can be replaced with `NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)` to suppress this warning.
        // But new `NSKeyedArchiver.archivedData` method throws. And `archive() -> Data` method doesn't have any mechanism how to return error.
        // For now keep the warning in favor of refactoring this method.
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }

    public var isKeyV2: Bool {
        for key in self where key.isKeyV2 {
            return true
        }
        return false
    }

}
