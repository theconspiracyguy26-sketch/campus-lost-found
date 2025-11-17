# campus-lost-found

# 📱 Campus Lost & Found App

A smart and scalable **Lost & Found system** designed for university campuses.  
Built with **Flutter** for cross-platform mobile support and integrated with a **Convolutional Neural Network (CNN)** model to intelligently match lost items with found reports.

---

## 🚀 Features

- **User Authentication**: Secure login and registration using OTP/email verification.
- **Post Lost/Found Items**: Upload item details with images and descriptions.
- **AI-Powered Matching**: CNN model trained to compare item images and suggest possible matches.
- **Search & Filter**: Quickly find items by category, keywords, or date.
- **Notifications**: Get alerts when a potential match is found.


---

## 🛠️ Tech Stack

- **Frontend**: [Flutter](https://flutter.dev/)  
- **Backend**:  Appwrite (configurable)  
- **AI Model**: Trained **CNN** (TensorFlow/Keras) for image similarity detection  
- **Database**: APPWRITE 
- **Deployment**: Dockerized backend + Flutter mobile app

---


---

## ⚙️ Installation & Setup

### Prerequisites
- Flutter SDK installed
- Python 3.8+ with TensorFlow/Keras
- Firebase/Appwrite account
- Docker (optional, for containerized deployment)

### Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/campus-lost-found.git
   cd campus-lost-found

cd flutter-app
flutter pub get
flutter run

cd model-server
pip install -r requirements.txt
python app.py
