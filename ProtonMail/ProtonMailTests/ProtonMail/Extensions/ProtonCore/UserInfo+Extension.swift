// Copyright (c) 2023 Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import ProtonCoreDataModel

extension UserInfo {
    // swiftlint:disable override_in_extension
    convenience override init() {
        self.init(
            maxSpace: nil,
            maxBaseSpace: nil,
            maxDriveSpace: nil,
            usedSpace: nil,
            usedBaseSpace: nil,
            usedDriveSpace: nil,
            language: nil,
            maxUpload: nil,
            role: nil,
            delinquent: nil,
            keys: nil,
            userId: nil,
            linkConfirmation: nil,
            credit: nil,
            currency: nil,
            createTime: nil,
            subscribed: nil,
            edmOptOut: nil
        )
    }
}
