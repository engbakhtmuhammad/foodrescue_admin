# Food Rescue Admin Panel

A comprehensive Flutter web application for restaurant management, built as a clone of the Dineout admin panel. This application provides a complete solution for managing restaurants, orders, users, content, and more.

## Features

### 🔐 Authentication System
- Role-based authentication (Admin, Restaurant Owner)
- Secure login with Firebase Auth
- Password reset functionality
- Session management

### 📊 Dashboard
- Real-time statistics and analytics
- Role-specific dashboard views
- Recent activity tracking
- Quick action buttons

### 🏪 Restaurant Management
- Complete restaurant CRUD operations
- Image upload and management
- Location and contact information
- Cuisine and facility associations
- Status management (Active/Inactive)

### 📋 Order Management
- Order listing with advanced filtering
- Status tracking and updates
- Customer and restaurant information
- Order details and item breakdown
- Export functionality

### 👥 User Management
- User listing and management
- Role-based filtering
- User status control
- Detailed user profiles

### 🎨 Content Management
- **Banners**: Promotional banner management
- **Cuisines**: Cuisine type management with images
- **Facilities**: Restaurant facility management
- **Gallery**: Image gallery with categories

### 🍽️ Menu Management
- Menu item CRUD operations
- Category-based organization
- Vegetarian/Non-vegetarian classification
- Availability status
- Price and preparation time management

### 🖼️ Gallery Management
- Image gallery with categories
- Category management
- Image upload and organization
- Preview functionality

### ⚙️ Settings
- Application configuration
- Payment settings
- Notification preferences
- Business information
- Order settings

## Technology Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **GetX**: State management and navigation
- **Flutter ScreenUtil**: Responsive design
- **Cached Network Image**: Image caching and loading

### Backend
- **Firebase Auth**: Authentication service
- **Cloud Firestore**: NoSQL database
- **Firebase Storage**: File storage
- **Firebase Analytics**: Analytics tracking

### UI/UX
- **Material Design 3**: Modern UI components
- **Custom widgets**: Reusable UI components
- **Responsive design**: Works on all screen sizes
- **Adaptive theming**: Professional color scheme

## Project Structure

```
lib/
├── app/
│   ├── bindings/           # Dependency injection
│   ├── constants/          # App constants and configurations
│   ├── controllers/        # Business logic controllers
│   ├── models/            # Data models
│   ├── routes/            # Navigation routes
│   ├── services/          # Core services
│   ├── utils/             # Utility functions
│   ├── views/             # UI screens
│   └── widgets/           # Reusable widgets
├── firebase_options.dart   # Firebase configuration
└── main.dart              # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (3.6.2 or higher)
- Dart SDK
- Firebase project setup
- Web browser for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd foodrescue_admin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication, Firestore, and Storage
   - Download and configure `firebase_options.dart`
   - Set up authentication providers

4. **Run the application**
   ```bash
   flutter run -d chrome
   ```

### Firebase Configuration

1. **Authentication**
   - Enable Email/Password authentication
   - Configure authorized domains

2. **Firestore Database**
   - Create collections: users, restaurants, orders, banners, cuisines, facilities, menus, galleries, settings
   - Set up security rules

3. **Storage**
   - Configure storage buckets for images
   - Set up security rules

## Usage

### Admin Features
- Full access to all modules
- User management and role assignment
- System-wide settings configuration
- Analytics and reporting

### Restaurant Owner Features
- Manage own restaurant information
- Menu and gallery management
- Order tracking and management
- Basic analytics for their restaurant

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please refer to the project documentation.

---

**Note**: This is a comprehensive admin panel clone for educational and development purposes.
