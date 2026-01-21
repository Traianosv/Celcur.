# Celcur eSIM App

A ready to use modern SwiftUI iOS app for purchasing and managing eSIM data plans worldwide.

## Features

### 🏪 Store
- Browse 150+ countries organized by regions
- Search functionality
- Standard data plans (1GB, 3GB, 5GB, 10GB)
- Digital Nomad unlimited plans
- Network provider information

### 📱 My eSIMs
- View purchased plans and status
- Install eSIM cards
- Data usage tracking
- Plan management

### 👤 Profile
- User authentication (email/password)
- Account management
- Support contact

## Screenshots

### Store View
Browse countries by region with interactive continent shapes and plan selection.

### Country Selection
Detailed plan offerings with standard and nomad options.

### Checkout Process
Secure payment options including Apple Pay simulation.

### Installation
Step-by-step eSIM installation guide.

## Getting Started

### Prerequisites
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Installation
1. Clone the repository
2. Open `Celcur.xcodeproj` in Xcode
3. Select an iOS simulator or device
4. Build and run (⌘R)

## App Architecture

### Files
- `ContentView.swift` - Main app interface with tab navigation
- `Models.swift` - Data models and sample data
- `Views.swift` - Reusable UI components

### Key Technologies
- **SwiftUI** - Declarative UI framework
- **Combine** - Reactive programming
- **Async/Await** - Modern concurrency
- **GeometryReader** - Custom continent shapes

## User Flow

1. **Browse**: Explore countries by region or search
2. **Select**: Choose between standard data plans or unlimited nomad passes
3. **Authenticate**: Create/login to account
4. **Checkout**: Secure payment with Apple Pay or card
5. **Install**: Follow guided eSIM installation
6. **Manage**: Monitor data usage and plan status

## Mock Features

The app includes realistic simulations for:
- Payment processing (2s delay)
- eSIM installation (3s activation)
- Authentication (1.5s login)
- Data usage visualization

## Contact

For support: support@celcur.com

## License

This project is for educational and demonstration purposes.
