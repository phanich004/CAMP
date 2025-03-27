//
//  ContentView.swift
//  CAMS
//
//  Created by Phanender Chalasani on 26/03/25.
//
import SwiftUI
import MapKit
struct CustomSecureField: View {
    @Binding var text: String
    @State private var isSecured = true
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isSecured {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
    }
}
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isAuthenticated = false
    @State private var isCreatingAccount = false
    @State private var showEmailError = false
    @State private var showPasswordError = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("CAMS Login")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .onChange(of: email) { _ in
                        showEmailError = !isValidEmail(email) && !email.isEmpty
                    }
                    .padding()
                
                if showEmailError {
                    Text("Please enter a valid email")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                CustomSecureField(text: $password, placeholder: "Password")
                    .padding()
                    .onChange(of: password) { _ in
                        showPasswordError = !isValidPassword(password) && !password.isEmpty
                    }
                
                if showPasswordError {
                    Text("Password must have at least 8 characters, one uppercase, one lowercase, one number, and one special character")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button("Login") {
                    if isValidEmail(email) && isValidPassword(password) {
                        isAuthenticated = true
                    }
                }
                .padding()
                .disabled(!isValidEmail(email) || !isValidPassword(password))
                
                NavigationLink("Forgot Password?", destination: ForgotPasswordView())
                    .foregroundColor(.blue)
                    .padding()
                
                Button("Create Account") {
                    isCreatingAccount = true
                }
                .padding()
                
                NavigationLink(destination: RegisterView(), isActive: $isCreatingAccount) {
                    EmptyView()
                }
                
                NavigationLink(destination: ProjectListView(), isActive: $isAuthenticated) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
}
struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var apiKey = ""
    @State private var showEmailError = false
    @State private var showPasswordError = false
    @State private var showPasswordMatchError = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Create Account")
                .font(.largeTitle)
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .onChange(of: email) { _ in
                    showEmailError = !isValidEmail(email) && !email.isEmpty
                }
                .padding()
            
            if showEmailError {
                Text("Please enter a valid email")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            CustomSecureField(text: $password, placeholder: "Password")
                .padding()
                .onChange(of: password) { _ in
                    showPasswordError = !isValidPassword(password) && !password.isEmpty
                    showPasswordMatchError = password != confirmPassword && !confirmPassword.isEmpty
                }
            
            if showPasswordError {
                Text("Password must have at least 8 characters, one uppercase, one lowercase, one number, and one special character")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            CustomSecureField(text: $confirmPassword, placeholder: "Confirm Password")
                .padding()
                .onChange(of: confirmPassword) { _ in
                    showPasswordMatchError = password != confirmPassword && !confirmPassword.isEmpty
                }
            
            if showPasswordMatchError {
                Text("Passwords do not match")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            TextField("PlanetScope API Key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Register") {
                if isValidEmail(email) && isValidPassword(password) && password == confirmPassword && !apiKey.isEmpty {
                    // Handle registration logic
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            .disabled(!isValidEmail(email) || !isValidPassword(password) || password != confirmPassword || apiKey.isEmpty)
        }
        .padding()
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
}
struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var codeSent = false
    @State private var verificationCode = ""
    @State private var isChangingPassword = false
    @State private var canResendCode = true
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    @State private var showEmailError = false
    
    var body: some View {
        VStack {
            Text("Reset Password")
                .font(.largeTitle)
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .onChange(of: email) { _ in
                    showEmailError = !isValidEmail(email) && !email.isEmpty
                }
                .padding()
            
            if showEmailError {
                Text("Please enter a valid email")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                if isValidEmail(email) {
                    codeSent = true
                    startTimer()
                }
            }) {
                Text(canResendCode ? "Send Code" : "Resend Code in \(timeRemaining)s")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canResendCode && isValidEmail(email) ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!canResendCode || !isValidEmail(email))
            .padding()
            
            if codeSent {
                TextField("Enter Code", text: $verificationCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()
                
                Button("Submit") {
                    if !verificationCode.isEmpty {
                        isChangingPassword = true
                    }
                }
                .padding()
                .disabled(verificationCode.isEmpty)
                
                NavigationLink(destination: ChangePasswordView(), isActive: $isChangingPassword) {
                    EmptyView()
                }
            }
        }
        .padding()
    }
    
    func startTimer() {
        canResendCode = false
        timeRemaining = 30
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.canResendCode = true
                self.timer?.invalidate()
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
struct ChangePasswordView: View {
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var showPasswordError = false
    @State private var showPasswordMatchError = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationHelper: NavigationHelper
    
    var body: some View {
        VStack {
            Text("Change Password")
                .font(.largeTitle)
                .padding()
            
            CustomSecureField(text: $newPassword, placeholder: "New Password")
                .padding()
                .onChange(of: newPassword) { _ in
                    showPasswordError = !isValidPassword(newPassword) && !newPassword.isEmpty
                    showPasswordMatchError = newPassword != confirmNewPassword && !confirmNewPassword.isEmpty
                }
            
            if showPasswordError {
                Text("Password must have at least 8 characters, one uppercase, one lowercase, one number, and one special character")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            CustomSecureField(text: $confirmNewPassword, placeholder: "Confirm New Password")
                .padding()
                .onChange(of: confirmNewPassword) { _ in
                    showPasswordMatchError = newPassword != confirmNewPassword && !confirmNewPassword.isEmpty
                }
            
            if showPasswordMatchError {
                Text("Passwords do not match")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Submit") {
                if isValidPassword(newPassword) && newPassword == confirmNewPassword {
                    // Handle password change logic
                    navigationHelper.isLoggedOut = true
                    
                    // Navigate back to login view
                    let count = presentationMode.wrappedValue.dismiss()
                    presentationMode.wrappedValue.dismiss()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            .disabled(!isValidPassword(newPassword) || newPassword != confirmNewPassword)
        }
        .padding()
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
}
struct ProjectListView: View {
    @State private var isAddingProject = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Projects")
                    .font(.largeTitle)
                    .padding()
                
                List {
                    // Existing projects will be listed here
                }
                
                Button("+ Add New Project") {
                    isAddingProject = true
                }
                .padding()
                
                NavigationLink(destination: AddProjectView(), isActive: $isAddingProject) {
                    EmptyView()
                }
            }
        }
    }
}
struct AddProjectView: View {
    @State private var projectName = ""
    @State private var cropName = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isSelectingArea = false
    @State private var showDateError = false
    @State private var dateErrorMessage = ""
    
    var body: some View {
        VStack {
            Text("New Project")
                .font(.largeTitle)
                .padding()
            
            TextField("Project Name", text: $projectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Crop Name", text: $cropName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                .padding()
                .onChange(of: startDate) { _ in
                    validateDates()
                }
            
            DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                .padding()
                .onChange(of: endDate) { _ in
                    validateDates()
                }
            
            if showDateError {
                Text(dateErrorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button("Submit") {
                if validateDates() && !projectName.isEmpty && !cropName.isEmpty {
                    isSelectingArea = true
                }
            }
            .padding()
            .disabled(showDateError || projectName.isEmpty || cropName.isEmpty)
            
            NavigationLink(destination: MapSelectionView(startDate: startDate, endDate: endDate), isActive: $isSelectingArea) {
                EmptyView()
            }
        }
        .padding()
    }
    
    func validateDates() -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Check if start date is before end date
        if startDate >= endDate {
            dateErrorMessage = "Start date must be earlier than end date"
            showDateError = true
            return false
        }
        
        // Check if end date is not in the future (Central Time)
        let centralTimeZone = TimeZone(identifier: "America/Chicago")!
        var components = calendar.dateComponents(in: centralTimeZone, from: currentDate)
        let currentDateCentralTime = calendar.date(from: components)!
        
        components = calendar.dateComponents(in: centralTimeZone, from: endDate)
        let endDateCentralTime = calendar.date(from: components)!
        
        if endDateCentralTime > currentDateCentralTime {
            dateErrorMessage = "End date cannot be in the future"
            showDateError = true
            return false
        }
        
        showDateError = false
        return true
    }
}
struct MapSelectionView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedCoordinates: [CLLocationCoordinate2D] = []
    var startDate: Date
    var endDate: Date
    
    var body: some View {
        VStack {
            Text("Select Area")
                .font(.largeTitle)
                .padding()
            
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none)
                .frame(height: 400)
                .cornerRadius(10)
                .padding()
                
            Button("Confirm Selection") {
                downloadSatelliteImage()
            }
            .padding()
        }
    }
    
    func downloadSatelliteImage() {
        // Send selectedCoordinates and date range to PlanetScope API
    }
}
class NavigationHelper: ObservableObject {
    @Published var isLoggedOut = false
}
struct ContentView: View {
    @StateObject var navigationHelper = NavigationHelper()
    
    var body: some View {
        NavigationView {
            if navigationHelper.isLoggedOut {
                LoginView()
            } else {
                LoginView()
            }
        }
        .environmentObject(navigationHelper)
    }
}
#Preview {
    ContentView()
}


