# 🤖 AI ChatBot - Powered by Gemini

A modern, feature-rich Flutter chatbot application that leverages Google's Gemini AI to provide intelligent conversational experiences. Built with clean architecture, state management, and a beautiful UI.

## ✨ Features

- **🤖 AI-Powered Conversations**: Powered by Google's Gemini AI for intelligent responses
- **📱 Modern UI/UX**: Beautiful gradient design with smooth animations
- **🖼️ Image Support**: Send images and get AI-generated responses
- **💾 Local Storage**: Chat history persistence using Hive database
- **🔄 Real-time Updates**: Live typing indicators and message status
- **📋 Copy to Clipboard**: Easy message copying functionality
- **🎨 Responsive Design**: Works seamlessly across different screen sizes
- **⚡ Fast Performance**: Optimized with BLoC pattern for efficient state management

## 🛠️ Tech Stack

- **Framework**: Flutter 3.8+
- **Language**: Dart
- **AI Integration**: Google Gemini API
- **State Management**: flutter_bloc
- **Local Storage**: Hive
- **HTTP Client**: http package
- **File Picker**: file_picker
- **UI Components**: Material Design 3

## 📋 Prerequisites

Before running this project, make sure you have:

- **Flutter SDK**: 3.8.0 or higher
- **Dart SDK**: 3.4.3 or higher
- **Android Studio** or **VS Code**
- **Android SDK**: API level 21 or higher
- **Google Gemini API Key**: Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd chatbot-master
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure API Key
Open `lib/main.dart` and replace the API key:
```dart
const APIKEY = 'YOUR_GEMINI_API_KEY_HERE';
```

### 4. Run the Application
```bash
# For debug build
flutter run

# For release build
flutter build apk --release
```

## 📱 App Structure

```
lib/
├── backend/
│   ├── saving_data.dart      # Local storage operations
│   └── send_message.dart     # API communication
├── bloc/
│   ├── bloc.dart            # Main BLoC implementation
│   ├── bloc_event.dart      # Event definitions
│   └── bloc_state.dart      # State definitions
├── component/
│   ├── chats_box.dart       # Chat message UI component
│   ├── component.dart       # Reusable UI components
│   ├── photo_box.dart       # Image display component
│   └── waiting_message.dart # Loading indicator
├── models/
│   ├── chat_model.dart      # Chat message data model
│   └── user_model.dart      # User data model
├── pages/
│   ├── homepage_1.dart      # Main chat interface
│   ├── image_page.dart      # Image upload interface
│   ├── login.dart          # User authentication
│   └── splash_screen.dart  # App launch screen
├── system/
│   └── auth.dart           # Authentication constants
└── main.dart               # App entry point
```

## 🔧 Configuration

### Android Configuration
The app is configured for Android with:
- Minimum SDK: 21
- Target SDK: Latest
- Java compatibility: 11
- Gradle version: 8.0

### Permissions
The app requires the following permissions:
- `INTERNET`: For API communication
- `ACCESS_NETWORK_STATE`: For network status monitoring

## 🎯 Usage

### Getting Started
1. **Launch the App**: Open the app and wait for the splash screen
2. **User Registration**: Enter your first and last name
3. **Start Chatting**: Begin conversations with the AI

### Features Usage
- **Text Messages**: Type your message and tap send
- **Image Upload**: Tap the image icon to upload and analyze images
- **Copy Messages**: Tap the copy icon on AI responses
- **Scroll to Bottom**: Use the floating action button to scroll to latest messages

## 🔒 Security

- API keys are stored in the source code (consider using environment variables for production)
- Local data is encrypted using Hive
- Network requests use HTTPS

## 🐛 Troubleshooting

### Common Issues

1. **Gradle Build Issues**
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean
   ```

2. **Memory Issues**
   - Reduce Gradle memory allocation in `android/gradle.properties`
   - Close other applications to free up memory

3. **API Key Issues**
   - Ensure your Gemini API key is valid
   - Check internet connectivity
   - Verify API quota limits

4. **File Picker Warnings**
   - These are harmless warnings and don't affect functionality
   - Can be ignored for development

### Performance Optimization
- Use release builds for better performance
- Clear app cache if experiencing slowdowns
- Monitor memory usage during image processing

## 📊 Dependencies

### Core Dependencies
```yaml
flutter_bloc: ^8.1.3      # State management
flutter_gemini: ^2.0.3    # Gemini AI integration
hive_flutter: ^1.1.0      # Local database
file_picker: ^6.1.1       # File selection
http: ^1.2.1              # HTTP requests
jumping_dot: ^0.0.6       # Loading animation
```

### Development Dependencies
```yaml
flutter_lints: ^3.0.0     # Code quality
flutter_test: ^3.8.0      # Testing framework
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google Gemini**: For providing the AI capabilities
- **Flutter Team**: For the amazing framework
- **BLoC Pattern**: For state management architecture
- **Hive**: For efficient local storage

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](../../issues) page
2. Create a new issue with detailed information
3. Include error logs and device information

## 🔄 Version History

- **v1.0.0**: Initial release with basic chat functionality
- **v1.0.1**: Added image support and UI improvements
- **v1.0.2**: Fixed Android build issues and performance optimizations

---

**Made with ❤️ using Flutter and Gemini AI**
