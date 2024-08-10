//
//  RoundedTextField.swift
//  HandyNotes
//
//  Created by Aman on 10/08/24.
//

import SwiftUI

struct RoundTextField: View {
    
    @State var title: String = "Title"
    @Binding var text: String
    @State var keyboardType:  UIKeyboardType = .default
    var textAlign:Alignment  = .leading
    var isPassword: Bool = false
    
    var body: some View {
        VStack{
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.customfont(.regular, fontSize: 18))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: textAlign)
                .foregroundColor(.gray50)
                .padding(.bottom, 4)
            
            
            if(isPassword) {
                SecureField("", text: $text)
                    .padding(15)
                    
                    .frame(height: 48)
                    .overlay {
                        RoundedRectangle(cornerRadius:  15)
                            .stroke(Color.gray70, lineWidth: 1)
                    }
                    .foregroundColor(.white)
                    .background(Color.gray70.opacity(0.8))
                    .cornerRadius(15)
            }else{
                TextField("", text: $text)
                    .padding(15)
                    .keyboardType(keyboardType)
                    .frame(height: 48)
                    .overlay {
                        RoundedRectangle(cornerRadius:  15)
                            .stroke(Color.gray70, lineWidth: 1)
                    }
                    .foregroundColor(.white)
                    .background(Color.gray70.opacity(0.8))
                    .cornerRadius(15)
            }
        }
    }
}

struct RoundTextField_Previews: PreviewProvider {
    @State static var txt: String = ""
    static var previews: some View {
        RoundTextField(text: $txt)
    }
}

