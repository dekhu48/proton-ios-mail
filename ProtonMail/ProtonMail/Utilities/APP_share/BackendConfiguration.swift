// Copyright (c) 2022 Proton Technologies AG
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

import ProtonCore_Doh
import ProtonCore_Environment

struct BackendConfiguration {
    typealias Environment = ProtonCore_Environment.Environment

    static let shared = BackendConfiguration()

    let environment: Environment

    var doh: DoH {
        environment.doh
    }

    var isProduction: Bool {
        switch environment {
        case .mailProd:
            return true
        default:
            return false
        }
    }

    init(environmentVariables: [String: String] = ProcessInfo.processInfo.environment) {
#if DEBUG
        if let domain = environmentVariables["MAIL_APP_API_DOMAIN"] {
            self.environment = .custom(domain)
        } else {
            self.environment = .mailProd
        }
#else
        self.environment = .mailProd
#endif
    }
}

extension BackendConfiguration {
    enum Arguments {
        static let disableToolbarSpotlight = "-toolbarSpotlightOff"
    }
}