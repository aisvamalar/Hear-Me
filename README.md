# 🎵 HearMe - AI-Powered Music Recommendation App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**Discover your next favorite song with AI-powered recommendations**

[Demo](#-demo) • [Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Architecture](#-architecture)

</div>

## 📖 About

HearMe is an intelligent music recommendation app that uses machine learning to suggest similar songs based on your search. Built with Flutter and powered by a Flask ML backend, it provides personalized music discovery with seamless user experience.

### 🎯 Key Highlights
- **AI-Powered**: Machine learning recommendations using cosine similarity
- **Cross-Platform**: Flutter app for iOS and Android
- **Secure Authentication**: Google Sign-in with Firebase
- **Cloud Storage**: Search history and favorites synced across devices
- **Real-time**: Instant recommendations with offline capability

## ✨ Features

### 🔐 **Authentication**
- Google Sign-in integration
- Firebase Authentication
- Secure user sessions
- Auto-login functionality

### 🎵 **Music Discovery**
- Search any song by name
- AI-powered similarity matching
- Top 5 song recommendations
- Artist and song details
- Direct music links (Musixmatch)

### 📱 **User Experience**
- Clean, intuitive interface
- Search history tracking
- Favorite songs management
- Social sharing capabilities
- Offline history access

### 🔧 **Technical Features**
- MVVM architecture pattern
- Real-time Firestore sync
- RESTful API integration
- Error handling & validation
- Responsive design

## 🚀 Demo

### Screenshots
*Coming Soon - Add your app screenshots here*

### Video Demo
*Coming Soon - Add demo video link*

## 🏗️ Architecture

### **Frontend (Flutter)**
```
lib/
├── models/          # Data models
├── views/           # UI screens
├── viewmodels/      # Business logic
├── services/        # API & Firebase services
├── utils/           # Utilities & constants
└── widgets/         # Reusable components
```

### **Backend (Flask)**
```python
# AI Recommendation Engine
- Machine Learning Models (Cosine Similarity)
- RESTful API endpoints
- Song dataset processing
- Real-time recommendations
```

### **Database (Firebase)**
```
Firestore Collections:
├── users/           # User profiles
├── search_history/  # Search logs
└── user_favorites/  # Saved songs
```

## 📋 Prerequisites

- **Flutter SDK** (>=3.0.0)
- **Python** (>=3.8)
- **Firebase Project** (Authentication + Firestore)
- **Git**

## 🛠️ Installation

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/hearme.git
cd hearme
```

### 2. Flutter Setup
```bash
# Install dependencies
flutter pub get

# Configure Firebase
# Add your google-services.json (Android) and GoogleService-Info.plist (iOS)

# Run the app
flutter run
```

### 3. Flask Backend Setup
```bash
# Navigate to backend directory
cd flask-backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install flask joblib pandas scikit-learn

# Place your ML model files
# - df_cleaned.pkl
# - cosine_sim.pkl

# Run Flask server
python app.py
```

### 4. Firebase Configuration
1. Create Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Google provider)
3. Enable Firestore Database
4. Download configuration files
5. Add to your Flutter project

## 📱 Usage

### **For Users**
1. **Login**: Sign in with Google account
2. **Search**: Type any song name
3. **Discover**: Get 5 AI-recommended similar songs
4. **Save**: Add favorites and view history
5. **Share**: Send recommendations to friends

### **For Developers**
```dart
// Example: Get music recommendations
final musicService = MusicService();
final recommendations = await musicService.getRecommendations('song_name');
```

## 🔧 Configuration

### **Environment Variables**
```bash
# Flask Backend
FLASK_ENV=development
FLASK_DEBUG=True
PORT=5000

# Firebase (Add to your app)
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

### **API Endpoints**
```
GET /                    # Welcome message
GET /recommend?song=name # Get recommendations
```

## 🧪 Testing

```bash
# Run Flutter tests
flutter test

# Run Flask tests
python -m pytest tests/
```

## 📦 Dependencies

### **Flutter Dependencies**
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  google_sign_in: ^6.1.6
  http: ^1.1.0
  provider: ^6.1.1
```

### **Python Dependencies**
```
Flask==2.3.3
joblib==1.3.2
pandas==2.0.3
scikit-learn==1.3.0
numpy==1.24.3
```

## 🤝 Contributing

1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** changes (`git commit -m 'Add AmazingFeature'`)
4. **Push** to branch (`git push origin feature/AmazingFeature`)
5. **Open** Pull Request

### **Development Guidelines**
- Follow MVVM architecture pattern
- Add unit tests for new features
- Update documentation
- Follow Flutter/Dart style guide

## 🐛 Known Issues

- [ ] Offline mode for recommendations
- [ ] iOS Google Sign-in configuration
- [ ] Large dataset loading optimization

## 🔮 Roadmap

- [ ] **Spotify Integration** - Direct music streaming
- [ ] **Playlist Creation** - Save multiple recommendations
- [ ] **Social Features** - Follow friends, share playlists
- [ ] **Advanced AI** - Mood-based recommendations
- [ ] **Dark Mode** - Theme customization
- [ ] **Web Version** - Browser-based access

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com

## 🙏 Acknowledgments

- **Flutter Team** - Amazing cross-platform framework
- **Firebase** - Backend-as-a-Service platform
- **Musixmatch** - Music metadata and links
- **Scikit-learn** - Machine learning algorithms
- **Open Source Community** - Inspiration and support

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/yourusername/hearme?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/hearme?style=social)
![GitHub issues](https://img.shields.io/github/issues/yourusername/hearme)
![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/hearme)

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

Made with ❤️ Flutter

</div>
