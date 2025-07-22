//
//  PrivacyView.swift
//  SpeakApper.AI
//
//  Created by Nurtileu Amanzhol on 13.07.2025.
//

import SwiftUICore
import SwiftUI

struct PrivacyView: View {
    let privacyPolicyContent: DocumentForm
    
    var body: some View {
        HStack{
            Text(privacyPolicyContent.title)
                .font(.title)
        }
        Text(privacyPolicyContent.version)
            .padding()
        VStack {
            ForEach(Array(zip(privacyPolicyContent.subtitles, privacyPolicyContent.content)), id: \.0) { subtitle, content in
                VStack{
                    Text(subtitle)
                        .padding()
                        .cornerRadius(8)
                    Text(content)
                }
            }
        }
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView(privacyPolicyContent: DocumentViewModel().privacyAndPolicy)
    }
}
