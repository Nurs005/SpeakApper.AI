//
//  SubscriptionOption.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 01.02.2025.
//

import SwiftUI


struct SubscriptionOptionsView: View {
    @Binding var selectedOption: SubscriptionOption?
    @Binding var isTrialEnabled: Bool

    var options: [SubscriptionOption]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.1.id) { index, option in
                subscriptionOptionRow(for: option)
               
            }

            if let selected = selectedOption, selected.isTrialEnabled {
                Toggle(isOn: $isTrialEnabled) {
                    Text("Попробовать бесплатно")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
                .toggleStyle(SwitchToggleStyle(tint: Color("ButtonColor")))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func subscriptionOptionRow(for option: SubscriptionOption ) -> some View {
        let isSelected = selectedOption == option

        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(option.title)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))

                HStack(spacing: 4) {
                    if !option.price.isEmpty {
                        Text(option.price)
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                    if !option.subtitle.isEmpty {
                        Text(option.subtitle)
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
            }

            Spacer()

            if option.isBestValue {
                Text("Сэкономьте 70%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white, lineWidth: 1)
                    )
            }

            Circle()
                .strokeBorder(Color.white, lineWidth: isSelected ? 3 : 1)
                .background(
                    isSelected
                        ? Circle().foregroundColor(Color.blue)
                        : Circle().foregroundColor(Color.clear)
                )
                .frame(width: 22, height: 22)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color("borderColor") : Color.gray.opacity(0.5), lineWidth: 0.65)
                .background(
                    isSelected
                        ? Color.blue.opacity(0.2)
                        : Color.clear
                )
        )
        .onTapGesture {
            print("Tapped option: \(option)")
            selectedOption = option
        }
    }
}
