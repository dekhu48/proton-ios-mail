// Copyright (c) 2024 Proton Technologies AG
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

import ProtonCoreUIFoundations
import SwiftUI

public struct UpsellPage: View {
    @ObservedObject private var model: UpsellPageModel
    private let entryPoint: UpsellPageEntryPoint
    private let onPurchaseTapped: (String) -> Void

    @Environment(\.verticalSizeClass)
    private var verticalSizeClass

    @State private var previousVerticalSizeClass: UserInterfaceSizeClass?
    @State private var enforceVerticalTiles = LayoutFix()
    @State private var hideLogo = LayoutFix()

    private var keyWindow: UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }

    private var windowSafeAreaInsets: UIEdgeInsets {
        keyWindow?.safeAreaInsets ?? .zero
    }

    private var infoSectionSpacing: CGFloat {
        if hideLogo.value {
            return 16
        } else {
            return 8
        }
    }

    private var layoutTilesVertically: Bool {
        verticalSizeClass == .compact || enforceVerticalTiles.value
    }

    public init(
        model: UpsellPageModel,
        entryPoint: UpsellPageEntryPoint,
        onPurchaseTapped: @escaping (String) -> Void
    ) {
        self.model = model
        self.entryPoint = entryPoint
        self.onPurchaseTapped = onPurchaseTapped
    }

    public var body: some View {
        PartialOverlayActionSheet { _ in
            if verticalSizeClass == .compact {
                HStack {
                    infoSection

                    interactiveArea
                        .padding(.top, -24)
                }
                .padding(.bottom, windowSafeAreaInsets.bottom)
            } else {
                VStack(spacing: 0) {
                    infoSection

                    Divider()
                        .overlay(Color.white.opacity(0.24))

                    interactiveArea
                        .padding(.top, 8)
                        .background(Color.white.opacity(0.04))
                }
                .padding(.bottom, windowSafeAreaInsets.bottom)
            }
        }
        .background(GeometryReader { geometry in
            Color.clear.preference(
                key: SizePreferenceKey.self,
                value: geometry.size
            )
        })
        .onPreferenceChange(SizePreferenceKey.self) {
            if verticalSizeClass != previousVerticalSizeClass {
                enforceVerticalTiles.reset()
                hideLogo.reset()
                previousVerticalSizeClass = verticalSizeClass
            }

            guard let keyWindow else {
                return
            }

            let keyWindowSize = keyWindow.frame.size

            if $0.width > keyWindowSize.width && !enforceVerticalTiles.isActivated {
                enforceVerticalTiles.activate()
            }

            let effectiveHeight = keyWindowSize.height - keyWindow.safeAreaInsets.top

            if $0.height > effectiveHeight && !hideLogo.isActivated {
                hideLogo.activate()
            }
        }
    }

    private var infoSection: some View {
        VStack(spacing: 8) {
            VStack(spacing: infoSectionSpacing) {
                if hideLogo.value {
                    Text(entryPoint.title(planName: model.plan.name))
                        .font(Font(UIFont.adjustedFont(forTextStyle: .title2, weight: .bold)))
                        .foregroundColor(ColorProvider.SidebarTextNorm)
                } else {
                    VStack(spacing: 20) {
                        Image(entryPoint.logo)
                            .padding(entryPoint.logoPadding)

                        Text(entryPoint.title(planName: model.plan.name))
                            .font(Font(UIFont.adjustedFont(forTextStyle: .title2, weight: .bold)))
                            .foregroundColor(ColorProvider.SidebarTextNorm)
                    }
                }

                Text(entryPoint.subtitle(planName: model.plan.name))
                    .font(Font(UIFont.adjustedFont(forTextStyle: .subheadline)))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(ColorProvider.SidebarTextWeak)
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading) {
                ForEach(model.plan.perks.indices, id: \.self) { idx in
                    VStack(alignment: .leading) {
                        HStack(spacing: 12) {
                            IconProvider[dynamicMember: model.plan.perks[idx].icon]
                                .frame(maxHeight: 20)
                                .foregroundColor(ColorProvider.IconWeak)
                                .preferredColorScheme(.dark)

                            Text(model.plan.perks[idx].description)
                                .font(Font(UIFont.adjustedFont(forTextStyle: .subheadline)))
                                .foregroundColor(ColorProvider.SidebarTextWeak)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if idx != model.plan.perks.indices.last {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.white.opacity(0.08))
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var interactiveArea: some View {
        VStack(spacing: 8) {
            Text(L10n.Upsell.autoRenewalNotice)
                .font(Font(UIFont.adjustedFont(forTextStyle: .footnote)))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(ColorProvider.SidebarTextNorm)

            ZStack {
                if layoutTilesVertically {
                    VStack {
                        tiles
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                } else {
                    HStack(alignment: .bottom, spacing: 7) {
                        tiles
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .visible(model.isBusy)
            }
        }
    }

    private var tiles: some View {
        ForEach(model.plan.purchasingOptions, id: \.identifier) { option in
            UpsellCTATile(planName: model.plan.name, purchasingOption: option) {
                onPurchaseTapped(option.identifier)
            }
        }
        .visible(!model.isBusy)
    }
}

extension UpsellPage {
    struct SizePreferenceKey: PreferenceKey {
        static let defaultValue: CGSize = .zero

        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            let newValue = nextValue()

            if newValue != defaultValue {
                value = newValue
            }
        }
    }

    struct LayoutFix {
        private(set) var value: Bool
        private let initialValue = false

        var isActivated: Bool {
            value != initialValue
        }

        init() {
            value = initialValue
        }

        mutating func activate() {
            value = !initialValue
        }

        mutating func reset() {
            value = initialValue
        }
    }
}

#Preview {
    UpsellPage(
        model: .init(
            plan: .init(
                name: "Mail Plus",
                perks: [
                    .init(icon: \.storage, description: L10n.PremiumPerks.storage),
                    .init(icon: \.inbox, description: String(format: L10n.PremiumPerks.emailAddresses, 10)),
                    .init(icon: \.globe, description: L10n.PremiumPerks.customEmailDomain),
                    .init(icon: \.gift, description: String(format: L10n.PremiumPerks.other, 7))
                ],
                purchasingOptions: [
                    .init(
                        identifier: "a",
                        cycleInMonths: 1,
                        monthlyPrice: "CHF 4.99",
                        billingPrice: "CHF 4.99",
                        isHighlighted: false,
                        discount: nil
                    ),
                    .init(
                        identifier: "b",
                        cycleInMonths: 12,
                        monthlyPrice: "CHF 3.99",
                        billingPrice: "CHF 47.88",
                        isHighlighted: true,
                        discount: 20
                    )
                ]
            )
        ),
        entryPoint: .header,
        onPurchaseTapped: { _ in }
    )
}
