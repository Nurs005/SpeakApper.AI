import SwiftUICore
import SwiftUI


struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel    
    let onFinish: () -> Void

    var body: some View {
        VStack {
                VStack {
                    TabView(selection: $viewModel.currentPage) {
                        ForEach(0..<viewModel.steps.count, id: \.self) { index in
                            viewModel.steps[index]
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    PageControl(numberOfPages: viewModel.steps.count, currentPage: $viewModel.currentPage)
                        .padding(.top, -10)

                    if viewModel.currentPage != 2 {
                        StartButtonView(viewModel: viewModel)
                    } else {
                        Button(action: {viewModel.showPaywall = true}) {
                            Text("Continue")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("ButtonColor"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(Color("BackgroundColor").ignoresSafeArea())
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .onChange(of: viewModel.showPaywall) {
            if viewModel.showPaywall {
                onFinish()
            }
        }
    }
}
