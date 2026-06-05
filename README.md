# Avo App

**Avo** is a modern, intelligently designed Flutter application built to seamlessly integrate smart health management, AI assistance, and secure digital payments into a single, cohesive user experience. 

---

## 📖 What is Avo App?

Avo is a **Smart Personal Assistant & Lifestyle App** designed to help users manage their daily health routines with ease. Whether it is tracking daily medications, consulting an AI-powered assistant for quick inquiries, or securely paying for premium in-app services, Avo handles it all. 

The application is built with a heavy emphasis on **Clean Architecture**, ensuring a highly responsive, scalable, and maintainable codebase. It features a fully adaptive UI that responds to system themes (Dark/Light mode) and dynamic screen sizes.

---

## 🚀 Usage (How It Works)

Avo is designed with a frictionless user journey in mind. Here is how a user interacts with the app:

### 1. Onboarding & Authentication
* **Welcome:** New users are greeted with a beautiful onboarding walkthrough explaining the app's core benefits.
* **Secure Access:** Users can quickly sign up, log in, or reset their passwords using the robust authentication module.

### 2. Smart Medication Reminders
* **Schedule:** Users navigate to the `Schedule` tab to manage their daily routines.
* **Add Medication:** Users can add new medications, specify dosages, and set exact reminder times. The app actively tracks these schedules and notifies the user accordingly.

### 3. AI Chatbot Interaction
* Users can access the AI Chatbot to ask quick lifestyle or health-related questions. The chat interface provides a natural, real-time conversational experience, making data retrieval conversational rather than transactional.

### 4. Managing Profile & Medical Data
* Inside the `Profile` tab, users have full control over their account and personal details.
* **Personal Info:** Users can edit critical physical metrics such as Height, Weight, and Blood Type using beautifully designed, interactive UI cards.
* **Preferences:** Users can toggle between Dark/Light themes and change localization settings seamlessly.

### 5. Secure Payments & Checkout
* When opting for premium features or services, users are routed to the Checkout process.
* **3D Card Management:** Users can add new credit cards and view them through a stunning 3D flip animation (showing the front details and the back CVV).
* **Payment Methods:** Users can select between stored cards, PayPal, or Apple Pay, culminating in a highly polished Success Bottom Sheet upon completion.

---

## ✨ Key Features

* **🩺 Medication Tracker:** Add, edit, and schedule daily medication reminders.
* **🤖 Integrated AI Chatbot:** Smart conversational UI for quick assistance.
* **💳 Advanced Checkout Flow:** 3D animated credit cards and dynamic payment selection.
* **👤 Comprehensive Profile:** Manage medical metrics (Blood type, weight, height) and account settings.
* **🌗 Adaptive Theming:** Flawless Dark and Light mode support relying on Flutter's core `ThemeData`.
* **🌍 Localization Ready:** Built to support multiple languages out of the box using `easy_localization`.

---

## 🛠️ Technical Architecture

This project strictly adheres to **Feature-First Clean Architecture** to separate concerns, making the codebase highly testable and readable.

* **Framework:** Flutter
* **Navigation:** `go_router` (Declarative routing utilizing `ShellRoute` to maintain a persistent Bottom Navigation Bar).
* **State Management:** `Provider` (specifically `ChangeNotifierProvider`).
* **Responsiveness:** `flutter_screenutil` combined with `device_preview` for pixel-perfect UI across all screen dimensions.
