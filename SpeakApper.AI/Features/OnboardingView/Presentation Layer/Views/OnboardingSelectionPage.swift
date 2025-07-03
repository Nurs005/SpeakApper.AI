//
//  OnboardingSelectionPage.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 30.01.2025.
//

import SwiftUI

struct OnboardingSelectionPage: View {
    let title: String
    let subtitle: String
    let options: [OptionModel]
    
    @Binding var currentPage: Int
    @State private var selectedOption: String?
    @ObservedObject var viewModel: OnboardingViewModel

        var body: some View {
                VStack {
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            //
                        }) {
                            Text("Skip")
                                .foregroundColor(.gray)
                                .font(.system(size: 17))
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .padding(.top, 40)
                            .font(.system(size: 21, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 16)
                        
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color("subtitle"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 24)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 17), GridItem(.flexible(), spacing: 17)], spacing: 17)  {
                ForEach(options, id: \.title) { option in
                    Button(action: {
                        selectedOption = option.title
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                            currentPage += 1 // OnboardingPurposePage
                            viewModel.nextPage()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("cardColor").opacity(0.8))
                                .frame(width: 172, height: 89)
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                            
                            HStack {
                                Image(option.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)

                                Text(option.title)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 8)

                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            
                            if selectedOption == option.title {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color("CircleColor"))
                                            .frame(width: 12, height: 12)
                                    }
                                    Spacer()
                                }
                                .padding(8)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 89)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedOption == option.title ? Color("CircleColor") : Color("borderColor"), lineWidth: 0.75)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer(minLength: 10)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
    }
}
