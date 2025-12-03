import SwiftUI

// --- Main App Entry ---
@main
struct CelcurApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// --- Main View ---
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var user: User? = nil
    @State private var purchasedPlans: [PurchasedPlan] = []
    
    // Navigation States
    @State private var selectedCountry: Country? = nil
    @State private var showAuthModal = false
    @State private var pendingPlan: (Plan, Country)? = nil
    @State private var showCheckout = false
    @State private var installItem: PurchasedPlan? = nil
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StoreView(
                user: user,
                onSelectCountry: { country in selectedCountry = country }
            )
            .tabItem {
                Image(systemName: "globe")
                Text("Store")
            }
            .tag(0)
            
            MyESimsView(
                user: user,
                purchasedPlans: purchasedPlans,
                onSignInReq: { selectedTab = 2 },
                onActivate: { id in
                    if let plan = purchasedPlans.first(where: { $0.id == id }) {
                        installItem = plan
                    }
                }
            )
            .tabItem {
                Image(systemName: "qrcode")
                Text("My eSIMs")
            }
            .tag(1)
            
            ProfileView(
                user: $user,
                onLogin: { newUser in
                    user = newUser
                    showAuthModal = false
                    if pendingPlan != nil {
                        showCheckout = true
                    }
                },
                onLogout: {
                    user = nil
                    selectedTab = 0
                }
            )
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(2)
        }
        .accentColor(BrandConfig.primaryColor)
        // Global Sheets
        .sheet(item: $selectedCountry) { country in
            PlanDetailView(
                country: country,
                onPurchase: { plan, country in
                    selectedCountry = nil // Close detail
                    if user == nil {
                        pendingPlan = (plan, country)
                        showAuthModal = true
                    } else {
                        pendingPlan = (plan, country)
                        showCheckout = true
                    }
                }
            )
        }
        .sheet(isPresented: $showAuthModal) {
            AuthView(onLogin: { newUser in
                user = newUser
                showAuthModal = false
                if pendingPlan != nil {
                    // Slight delay to allow modal to close before opening next
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCheckout = true
                    }
                }
            })
        }
        .sheet(isPresented: $showCheckout) {
            if let (plan, country) = pendingPlan {
                CheckoutView(
                    plan: plan,
                    country: country,
                    onConfirm: {
                        let newPurchase = PurchasedPlan(plan: plan, country: country, status: .notInstalled)
                        purchasedPlans.insert(newPurchase, at: 0)
                        showCheckout = false
                        pendingPlan = nil
                        selectedTab = 1 // Go to My eSIMs
                        
                        // Auto Trigger Install
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            installItem = newPurchase
                        }
                    }
                )
            }
        }
        .overlay(
            Group {
                if let item = installItem {
                    InstallGuideOverlay(
                        item: item,
                        onClose: { installItem = nil },
                        onComplete: { id in
                            if let index = purchasedPlans.firstIndex(where: { $0.id == id }) {
                                purchasedPlans[index].status = .active
                            }
                        }
                    )
                }
            }
        )
    }
}

// --- Store View ---
struct StoreView: View {
    let user: User?
    let onSelectCountry: (Country) -> Void
    
    @State private var searchTerm = ""
    @State private var activeRegion = "All"
    @State private var isLoading = true
    
    let regions = [
        ("Europe", 22, Color.blue),
        ("Asia", 14, Color.pink),
        ("Americas", 12, Color.green),
        ("Middle East", 5, Color.purple),
        ("Africa", 6, Color.orange),
        ("Oceania", 3, Color.yellow)
    ]
    
    var filteredCountries: [Country] {
        if activeRegion == "All" {
            return countriesDB.filter {
                searchTerm.isEmpty ? false : $0.name.lowercased().contains(searchTerm.lowercased())
            }
        } else {
            return countriesDB.filter { $0.region == activeRegion }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search 150+ countries...", text: $searchTerm)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView().padding(.top, 50)
                    } else {
                        if !searchTerm.isEmpty || activeRegion != "All" {
                            // List View
                            if activeRegion != "All" {
                                HStack {
                                    Button(action: { activeRegion = "All" }) {
                                        HStack {
                                            Image(systemName: "arrow.left")
                                            Text(activeRegion).font(.title2).bold()
                                        }
                                    }
                                    Spacer()
                                }.padding(.horizontal)
                            }
                            
                            LazyVStack(spacing: 12) {
                                ForEach(filteredCountries) { country in
                                    Button(action: { onSelectCountry(country) }) {
                                        HStack {
                                            Text(country.flag).font(.largeTitle)
                                            VStack(alignment: .leading) {
                                                Text(country.name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Text(country.network)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right").foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    }
                                }
                            }.padding(.horizontal)
                            
                        } else {
                            // Home View
                            VStack(spacing: 24) {
                                // Digital Nomad Banner
                                ZStack(alignment: .leading) {
                                    LinearGradient(gradient: Gradient(colors: [BrandConfig.primaryColor, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Digital Nomad?")
                                            .font(.title2).bold()
                                        Text("Get unlimited data in your destination.")
                                            .font(.subheadline)
                                            .opacity(0.9)
                                        
                                        HStack {
                                            Image(systemName: "laptopcomputer")
                                            Text("Remote Ready")
                                                .font(.caption).bold()
                                        }
                                        .padding(8)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(8)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    
                                    Image(systemName: "globe")
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(.white.opacity(0.2))
                                        .offset(x: 200, y: 40)
                                }
                                .frame(height: 160)
                                .cornerRadius(20)
                                .padding(.horizontal)
                                .clipped()
                                
                                // Region Grid
                                VStack(alignment: .leading) {
                                    Text("Browse by Region")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                        ForEach(regions, id: \.0) { region in
                                            Button(action: { activeRegion = region.0 }) {
                                                ZStack(alignment: .topLeading) {
                                                    Color.white
                                                    
                                                    // Continent Path Background
                                                    ContinentShape(region: region.0)
                                                        .fill(BrandConfig.primaryColor.opacity(0.1))
                                                        .frame(width: 100, height: 100)
                                                        .offset(x: 60, y: 60)
                                                        .rotationEffect(.degrees(-10))
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text(region.0)
                                                            .font(.headline)
                                                            .foregroundColor(.primary)
                                                        Text("\(region.1) Countries")
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                        
                                                        Spacer()
                                                        
                                                        HStack {
                                                            Spacer()
                                                            Image(systemName: "chevron.right")
                                                                .foregroundColor(.gray)
                                                                .padding(6)
                                                                .background(Color(.systemGray6))
                                                                .clipShape(Circle())
                                                        }
                                                    }
                                                    .padding()
                                                }
                                                .frame(height: 140)
                                                .cornerRadius(16)
                                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle(BrandConfig.appName)
            .navigationBarItems(trailing: user != nil ? Text(user!.name).font(.caption).padding(6).background(Color.blue.opacity(0.1)).cornerRadius(8) : nil)
            .onAppear {
                // Simulate loading
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isLoading = false
                }
            }
        }
    }
}

// --- Plan Detail View ---
struct PlanDetailView: View {
    let country: Country
    let onPurchase: (Plan, Country) -> Void
    
    @State private var mode = "standard"
    @Environment(\.presentationMode) var presentationMode
    
    var nomadPlan: Plan {
        Plan(id: "nomad", data: "Unlimited", days: 30, price: country.nomadPrice)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack {
                HStack {
                    Spacer()
                    Text(country.name).font(.headline)
                    Spacer()
                }
                .padding(.top)
                .overlay(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }.padding(.leading), alignment: .leading
                )
                
                HStack(spacing: 20) {
                    Text(country.flag).font(.system(size: 60))
                    VStack(alignment: .leading) {
                        Text(country.name).font(.title).bold()
                        Text("Provided by \(country.network)").font(.subheadline).foregroundColor(.gray)
                    }
                    Spacer()
                }.padding()
            }
            .background(Color.white)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Toggle
                    HStack {
                        modeButton(title: "Standard", icon: "iphone", mode: "standard")
                        modeButton(title: "Digital Nomad", icon: "briefcase", mode: "nomad")
                    }
                    .padding(4)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                    
                    if mode == "standard" {
                        ForEach(standardPlans) { plan in
                            PlanCard(plan: plan, onTap: { onPurchase(plan, country) })
                        }
                    } else {
                        // Nomad Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Nomad Pass").font(.title2).bold()
                                    Text("Work remotely from \(country.name)").font(.caption).opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "laptopcomputer").font(.largeTitle)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Unlimited Data", systemImage: "checkmark")
                                Label("30 Days Validity", systemImage: "checkmark")
                                Label("Hotspot Enabled", systemImage: "checkmark")
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Monthly Price").font(.caption)
                                    Text("$\(String(format: "%.2f", nomadPlan.price))").font(.title2).bold()
                                }
                                Spacer()
                                Button(action: { onPurchase(nomadPlan, country) }) {
                                    Text("Get Started")
                                        .bold()
                                        .foregroundColor(Color.purple)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(20)
                    }
                    
                    // Info Box
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Provider Information").font(.headline)
                        HStack { Text("Roaming"); Spacer(); Text("Enabled").bold() }
                        HStack { Text("APN"); Spacer(); Text("automatic").bold() }
                        HStack { Text("Tethering"); Spacer(); Text("Allowed").foregroundColor(.green) }
                    }
                    .font(.caption)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                }
                .padding()
            }
            .background(Color(.systemGray6))
        }
    }
    
    func modeButton(title: String, icon: String, mode: String) -> some View {
        Button(action: { self.mode = mode }) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(self.mode == mode ? Color.white : Color.clear)
            .cornerRadius(10)
            .foregroundColor(self.mode == mode ? .black : .gray)
            .shadow(color: self.mode == mode ? Color.black.opacity(0.1) : .clear, radius: 2)
        }
    }
}

struct PlanCard: View {
    let plan: Plan
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(plan.data).font(.title).bold().foregroundColor(.primary)
                        Text("Valid for \(plan.days) days").font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    Text("$\(String(format: "%.2f", plan.price))")
                        .bold()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(BrandConfig.primaryColor.opacity(0.1))
                        .foregroundColor(BrandConfig.primaryColor)
                        .cornerRadius(8)
                }
                Divider().padding(.vertical, 8)
                Text("Buy Now").bold().frame(maxWidth: .infinity).foregroundColor(.white).padding().background(BrandConfig.primaryColor).cornerRadius(10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 2)
        }
    }
}

// --- Checkout View ---
struct CheckoutView: View {
    let plan: Plan
    let country: Country
    let onConfirm: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var paymentMethod = "apple_pay"
    @State private var isProcessing = false
    
    // Form
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvc = ""
    @State private var zip = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Checkout").font(.title2).bold()
                Spacer()
                Button("Close") { presentationMode.wrappedValue.dismiss() }
            }.padding()
            
            // Summary
            HStack {
                VStack(alignment: .leading) {
                    Text("\(country.name) eSIM").font(.headline)
                    Text("\(plan.data) / \(plan.days) Days").font(.caption).foregroundColor(.gray)
                }
                Spacer()
                Text("$\(String(format: "%.2f", plan.price))").font(.title2).bold()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Method
            HStack(spacing: 12) {
                PaymentButton(title: " Pay", isSelected: paymentMethod == "apple_pay") { paymentMethod = "apple_pay" }
                PaymentButton(title: "Card", isSelected: paymentMethod == "card") { paymentMethod = "card" }
            }.padding(.horizontal)
            
            if paymentMethod == "apple_pay" {
                VStack {
                    Text("Pay securely with Apple Pay").font(.caption).foregroundColor(.gray)
                    RoundedRectangle(cornerRadius: 4).frame(width: 40, height: 20).foregroundColor(.gray.opacity(0.3))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    TextField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    
                    HStack {
                        TextField("MM/YY", text: $expiry).padding().background(Color.white).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                        TextField("CVC", text: $cvc).padding().background(Color.white).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    }
                    
                    TextField("ZIP Code", text: $zip).padding().background(Color.white).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    
                    HStack {
                        Image(systemName: "lock.fill")
                        Text("Payments secured by Stripe")
                    }.font(.caption).foregroundColor(.gray)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                isProcessing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isProcessing = false
                    onConfirm()
                }
            }) {
                HStack {
                    if isProcessing {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(isProcessing ? "Processing..." : (paymentMethod == "apple_pay" ? "Pay with  Pay" : "Pay $\(String(format: "%.2f", plan.price))"))
                }
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(paymentMethod == "apple_pay" ? Color.black : BrandConfig.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isProcessing)
            .padding()
        }
    }
}

struct PaymentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? BrandConfig.primaryColor.opacity(0.1) : Color.clear)
                .foregroundColor(isSelected ? BrandConfig.primaryColor : .gray)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? BrandConfig.primaryColor : Color.gray.opacity(0.3)))
                .cornerRadius(12)
        }
    }
}

// --- Install Guide Overlay (Simulating iOS Sheet) ---
struct InstallGuideOverlay: View {
    let item: PurchasedPlan
    let onClose: () -> Void
    let onComplete: (UUID) -> Void
    
    @State private var step = "start" // start, installing, success, manual
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all).onTapGesture { onClose() }
            
            VStack(spacing: 0) {
                if step == "start" {
                    VStack(spacing: 20) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 40))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        
                        Text("Add Cellular Plan")
                            .font(.title2).bold()
                        
                        Text("A cellular plan from **\(BrandConfig.appName)** is ready to be added to this iPhone.")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                step = "installing"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { step = "success" }
                            }) {
                                Text("Continue").bold().frame(maxWidth: .infinity).padding().background(Color.blue).foregroundColor(.white).cornerRadius(12)
                            }
                            
                            Button(action: { step = "manual" }) {
                                Text("Enter Details Manually").bold().foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(30)
                } else if step == "installing" {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Activating eSIM...").bold()
                        Text("This may take a moment.").font(.caption).foregroundColor(.gray)
                    }
                    .frame(height: 300)
                } else if step == "success" {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Cellular Plan Added").font(.title2).bold()
                        Text("Your **\(item.country.name)** data plan is now active.").multilineTextAlignment(.center).foregroundColor(.gray)
                        
                        Button(action: {
                            onComplete(item.id)
                            onClose()
                        }) {
                            Text("Done").bold().frame(maxWidth: .infinity).padding().background(Color.black).foregroundColor(.white).cornerRadius(12)
                        }
                    }
                    .padding(30)
                } else if step == "manual" {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Button("Back") { step = "start" }
                            Spacer()
                            Text("Manual Details").bold()
                            Spacer()
                            Button("Done") { onClose() }.hidden()
                        }
                        
                        Text("Go to Settings > Cellular > Add eSIM and enter these details.").font(.caption).foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text("SM-DP+ Address").font(.caption).foregroundColor(.gray)
                            Text("rsp.truphone.com").font(.system(.body, design: .monospaced))
                        }.padding().frame(maxWidth: .infinity, alignment: .leading).background(Color(.systemGray6)).cornerRadius(8)
                        
                        VStack(alignment: .leading) {
                            Text("Activation Code").font(.caption).foregroundColor(.gray)
                            Text("LOPA-1203-3948-2938").font(.system(.body, design: .monospaced))
                        }.padding().frame(maxWidth: .infinity, alignment: .leading).background(Color(.systemGray6)).cornerRadius(8)
                    }
                    .padding(24)
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding()
        }
    }
}

// --- My eSIMs View ---
struct MyESimsView: View {
    let user: User?
    let purchasedPlans: [PurchasedPlan]
    let onSignInReq: () -> Void
    let onActivate: (UUID) -> Void
    
    @State private var filter = "Active"
    
    var body: some View {
        NavigationView {
            VStack {
                if user == nil {
                    VStack(spacing: 20) {
                        Image(systemName: "lock.circle").font(.system(size: 60)).foregroundColor(.gray)
                        Text("Sign in Required").font(.title2).bold()
                        Text("Please sign in to view your purchased eSIMs.").foregroundColor(.gray)
                        Button("Sign In") { onSignInReq() }.padding().background(BrandConfig.primaryColor).foregroundColor(.white).cornerRadius(8)
                    }
                } else {
                    // Filter
                    Picker("Filter", selection: $filter) {
                        Text("Active").tag("Active")
                        Text("Expired").tag("Expired")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if purchasedPlans.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: "bag").font(.largeTitle).foregroundColor(.gray)
                            Text("No active plans").bold()
                            Text("Purchase a plan to get started.").foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(purchasedPlans) { item in
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text(item.country.flag).font(.title)
                                            VStack(alignment: .leading) {
                                                Text(item.country.name).font(.headline)
                                                Text("ID: ...\(item.iccid.suffix(4)) • \(item.plan.data)").font(.caption).fontDesign(.monospaced).foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Text(item.status.rawValue)
                                                .font(.caption).bold()
                                                .padding(6)
                                                .background(item.status == .active ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                                                .foregroundColor(item.status == .active ? .green : .blue)
                                                .cornerRadius(6)
                                        }
                                        
                                        if item.status == .active {
                                            ProgressView(value: 0.1).accentColor(BrandConfig.primaryColor)
                                            HStack {
                                                Text("0.1 GB used").font(.caption).foregroundColor(.gray)
                                                Spacer()
                                                Text("\(item.plan.data) Total").font(.caption).foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Divider()
                                        
                                        if item.status == .notInstalled {
                                            Button(action: { onActivate(item.id) }) {
                                                Text("Install eSIM").bold().frame(maxWidth: .infinity).padding(8).background(BrandConfig.primaryColor).foregroundColor(.white).cornerRadius(8)
                                            }
                                        } else {
                                            Button("View Details") {}.frame(maxWidth: .infinity).padding(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2)
                                }
                            }.padding()
                        }
                        .background(Color(.systemGray6))
                    }
                }
            }
            .navigationTitle("My eSIMs")
        }
    }
}

// --- Profile / Auth Views ---
struct User {
    let id: String
    let name: String
    let email: String
}

struct AuthView: View {
    let onLogin: (User) -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text(isSignUp ? "Create Account" : "Welcome Back").font(.largeTitle).bold().frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            Button(action: {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isLoading = false
                    onLogin(User(id: "123", name: email.components(separatedBy: "@").first ?? "User", email: email))
                }
            }) {
                HStack {
                    if isLoading { ProgressView().padding(.trailing) }
                    Text(isSignUp ? "Sign Up" : "Log In").bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(BrandConfig.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(email.isEmpty || password.isEmpty)
            
            Button(action: { isSignUp.toggle() }) {
                Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(30)
    }
}

struct ProfileView: View {
    @Binding var user: User?
    let onLogin: (User) -> Void
    let onLogout: () -> Void
    
    var body: some View {
        if let currentUser = user {
            NavigationView {
                List {
                    Section {
                        HStack(spacing: 16) {
                            Circle().fill(BrandConfig.primaryColor.opacity(0.1)).frame(width: 60, height: 60)
                                .overlay(Image(systemName: "person.fill").foregroundColor(BrandConfig.primaryColor))
                            VStack(alignment: .leading) {
                                Text(currentUser.name).font(.headline)
                                Text(currentUser.email).font(.subheadline).foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    Section {
                        Label("Payment Methods", systemImage: "creditcard")
                        Label("Contact Support", systemImage: "envelope")
                        Label("Terms & Privacy", systemImage: "hand.raised")
                    }
                    
                    Section {
                        Button(action: onLogout) {
                            Label("Log Out", systemImage: "arrow.right.square").foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("Profile")
            }
        } else {
            AuthView(onLogin: onLogin)
        }
    }
}

// --- Helpers: Detailed Shapes ---
struct ContinentShape: Shape {
    let region: String
    
    func path(in rect: CGRect) -> Path {
        // Simplified Bezier paths for demo purposes to mimic high fidelity icons
        // In a real app, you'd use SVG assets or exact UIBezierPaths
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        switch region {
        case "Americas":
            path.move(to: CGPoint(x: w*0.3, y: h*0.1))
            path.addCurve(to: CGPoint(x: w*0.7, y: h*0.3), control1: CGPoint(x: w*0.6, y: h*0.1), control2: CGPoint(x: w*0.8, y: h*0.2))
            path.addCurve(to: CGPoint(x: w*0.6, y: h*0.8), control1: CGPoint(x: w*0.9, y: h*0.5), control2: CGPoint(x: w*0.7, y: h*0.7))
            path.addCurve(to: CGPoint(x: w*0.4, y: h*0.9), control1: CGPoint(x: w*0.5, y: h*0.85), control2: CGPoint(x: w*0.45, y: h*0.95))
            path.addCurve(to: CGPoint(x: w*0.3, y: h*0.1), control1: CGPoint(x: w*0.2, y: h*0.5), control2: CGPoint(x: w*0.1, y: h*0.2))
        case "Europe":
            path.move(to: CGPoint(x: w*0.4, y: h*0.2))
            path.addLine(to: CGPoint(x: w*0.7, y: h*0.2))
            path.addCurve(to: CGPoint(x: w*0.6, y: h*0.5), control1: CGPoint(x: w*0.8, y: h*0.3), control2: CGPoint(x: w*0.7, y: h*0.4))
            path.addLine(to: CGPoint(x: w*0.3, y: h*0.4))
            path.closeSubpath()
        case "Asia":
            path.move(to: CGPoint(x: w*0.2, y: h*0.2))
            path.addLine(to: CGPoint(x: w*0.8, y: h*0.2))
            path.addLine(to: CGPoint(x: w*0.7, y: h*0.7))
            path.addLine(to: CGPoint(x: w*0.3, y: h*0.6))
            path.closeSubpath()
        case "Africa":
            path.move(to: CGPoint(x: w*0.5, y: h*0.2))
            path.addCurve(to: CGPoint(x: w*0.8, y: h*0.4), control1: CGPoint(x: w*0.7, y: h*0.2), control2: CGPoint(x: w*0.8, y: h*0.3))
            path.addLine(to: CGPoint(x: w*0.5, y: h*0.9))
            path.addCurve(to: CGPoint(x: w*0.2, y: h*0.4), control1: CGPoint(x: w*0.3, y: h*0.7), control2: CGPoint(x: w*0.2, y: h*0.5))
            path.closeSubpath()
        default:
            path.addEllipse(in: rect.insetBy(dx: w*0.2, dy: h*0.2))
        }
        
        return path
    }
}
