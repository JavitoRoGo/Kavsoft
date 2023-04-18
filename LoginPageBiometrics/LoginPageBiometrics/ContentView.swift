//
//  ContentView.swift
//  LoginPageBiometrics
//
//  Created by Javier Rodríguez Gómez on 30/12/22.
//

import LocalAuthentication
import SwiftUI

struct ContentView: View {
    @AppStorage("status") var logged = false
    
    var body: some View {
        NavigationStack {
            if logged {
                Text("User logged in...")
                    .navigationTitle("Home")
                    .toolbar(.hidden)
                    .preferredColorScheme(.light)
            } else {
                Home()
                    .preferredColorScheme(.dark)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Home: View {
    @State var userName = ""
    @State var password = ""
    // when first time user logged in via email store this for future biometric login...
    @AppStorage("stored_User") var user = "reply.kavsoft@gmail.com"
    @AppStorage("status") var logged = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 250)
                .padding(.vertical)
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Login")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text("Please sign in to continue")
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer(minLength: 0)
            }
            .padding()
            
            HStack {
                Image(systemName: "envelope")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 35)
                TextField("EMAIL", text: $userName)
                    .textInputAutocapitalization(.never)
            }
            .padding()
            .background(.white.opacity(userName == "" ? 0 : 0.12))
            .cornerRadius(15)
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "lock")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 35)
                SecureField("PASSWORD", text: $password)
                    .textInputAutocapitalization(.never)
            }
            .padding()
            .background(.white.opacity(password == "" ? 0 : 0.12))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top)
            
            HStack(spacing: 15) {
                Button {
                    
                } label: {
                    Text("LOGIN")
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 150)
                        .background(Color("green"))
                        .clipShape(Capsule())
                }
                .opacity(userName != "" && password != "" ? 1 : 0.5)
                .disabled(userName != "" && password != "" ? false : true)
                
                if getBioMetricStatus() {
                    Button {
                        authenticateUser()
                    } label: {
                        // getting biometric type...
                        Image(systemName: LAContext().biometryType == .faceID ? "faceid" : "touchid")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color("green"))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.top)
            
            // Forget button...
            Button {
                
            } label: {
                Text("Forget password?")
                    .foregroundColor(Color("green"))
            }
            .padding(.top, 8)
            
            Spacer(minLength: 0)
            
            // SignUp...
            HStack(spacing: 5) {
                Text("Don't have an account?")
                    .foregroundColor(.white.opacity(0.6))
                Button {
                    
                } label: {
                    Text("Signup")
                        .fontWeight(.heavy)
                        .foregroundColor(Color("green"))
                }
            }
            .padding(.vertical)
        }
        .background(Color("bg").ignoresSafeArea(.all, edges: .all))
        .animation(.easeOut, value: 1)
    }
    
    // Getting biometricType...
    func getBioMetricStatus() -> Bool {
        let scanner = LAContext()
        if userName == user && scanner.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: .none) {
            return true
        }
        return false
    }
    
    // autenticate user...
    func authenticateUser() {
        let scanner = LAContext()
        scanner.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "To unlock \(userName)") { (status, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            // setting logged status as true...
            withAnimation(.easeOut) {
                logged = true
            }
        }
    }
}
