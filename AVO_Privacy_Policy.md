# Privacy Policy for AVO

**Effective Date:** July 3, 2026  
**Developer/Company Name:** TYLDA / AVO Development Team  
**Contact Email:** `support@tylda.com`  

---

## 1. Introduction
Welcome to **AVO** ("we," "our," or "us"). We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application (**AVO**), which provides digital health ecosystem services, AI-powered medical test scanning, and administrative healthcare management.

By downloading, accessing, or using AVO, you agree to the collection and use of information in accordance with this policy. If you do not agree with the terms of this privacy policy, please do not access the application.

---

## 2. Information We Collect
We collect personal and sensitive user data only to the extent necessary to provide and improve the healthcare functionalities of the app. Based on the app's features, we collect the following types of information:

### A. Health & Medical Information
* **Medical Documents & Lab Results:** When you use the **AI Scanner** feature, we process images of medical test results, laboratory reports, and healthcare prescriptions that you scan or upload.
* **Health Profiles:** Information regarding patient histories, medical queries, and saved analysis results.

### B. Device & Hardware Permissions
To provide specific features, AVO requests access to certain device hardware:
* **Camera (`android.permission.CAMERA`):** Required to capture photos of laboratory results and medical documents directly within the app for optical character recognition (OCR) scanning.
* **Photo Library / Gallery:** Required to upload pre-existing images of medical reports from your device's storage.
* **Microphone & Audio Recording:** Required for voice commands, speech-to-text functionalities, and audio notes (utilizing audio recording and speech recognition modules).

### C. Account & Usage Data
* **User Authentication & Profile:** Name, email address, user role (Patient or Healthcare Administrator), and login credentials stored via cloud authentication services.
* **In-App Activity & Gamification:** Data regarding your usage of application features, such as your point balance and transaction history (e.g., points deducted per AI scan via `PointsService`).

---

## 3. How We Use Your Information
We use the collected information for the following specific purposes:
1. **AI Medical Analysis & OCR:** We use Google ML Kit to extract text from your scanned medical images on-device/in-cloud, and process that text using **Google Gemini AI** to generate structured, understandable medical summaries and formatting (Markdown).
2. **Data Storage & Syncing:** To save your medical analysis history locally on your device (using Hive local databases) and synchronize it across your devices (using Google Firebase Cloud Firestore and Realtime Database).
3. **Voice & Speech Processing:** To convert spoken queries into text and read out medical summaries using Text-to-Speech (TTS) services.
4. **App Improvement & Security:** To monitor application performance, prevent fraudulent use of account points, and ensure the security of patient ecosystems.

---

## 4. Third-Party Services & Data Sharing
We **do not sell, rent, or trade** your personal health data to marketing agencies or unauthorized third parties. However, to power our cloud and AI infrastructure, we share specific data with trusted third-party service providers:

| Third-Party Service | Purpose | Data Shared |
| :--- | :--- | :--- |
| **Google Firebase (Cloud Firestore & Auth)** | Cloud database storage, user authentication, and real-time syncing. | Account profile, encrypted health summaries, and application state. |
| **Google ML Kit** | Optical Character Recognition (OCR) to read text from images. | Images of medical test reports (processed securely for text extraction). |
| **Google Gemini API / Cloud AI** | Artificial Intelligence processing to analyze and summarize lab results. | Extracted text from medical reports (stripped of unnecessary personal identifiers where possible). |

*Each of these providers operates under strict data security and privacy compliance standards (such as HIPAA/GDPR readiness where applicable).*

---

## 5. Data Storage, Retention, and Security
* **Local Storage:** Scanned reports and offline caches are stored securely on your device using Hive local storage.
* **Cloud Storage:** Cloud-synced data is hosted on secure Firebase servers with encryption in transit (HTTPS/TLS) and encryption at rest.
* **Retention:** We retain your medical history and account data as long as your account remains active. If you choose to delete your account, your data will be permanently purged from our active databases in accordance with our retention schedules.

---

## 6. User Rights & Data Deletion (Google Play Mandate)
In compliance with Google Play’s Data Safety rules, you have full control over your personal and medical data:
* **Access and Export:** You can view your saved medical analyses directly within the app at any time.
* **Account and Data Deletion:** You have the right to request the complete deletion of your account and associated personal/health data. 
* **How to request deletion:** You can delete your saved analysis locally within the app, or request complete account and cloud data deletion by emailing us at `support@tylda.com` with the subject line *"Data Deletion Request."* We will process and complete your deletion request within 30 days.

---

## 7. Children’s Privacy
AVO is not intended for use by unattended children under the age of 13 (or 16 in certain jurisdictions). We do not knowingly collect personally identifiable information from children without parental or legal guardian consent. If we become aware that a child's data has been collected without appropriate consent, we will take immediate steps to delete that information.

---

## 8. Changes to This Privacy Policy
We may update our Privacy Policy from time to time to reflect changes in our tech stack, new features, or regulatory updates. We will notify you of any changes by updating the "Effective Date" at the top of this policy and, where appropriate, providing an in-app notification.

---

## 9. Contact Us
If you have any questions, concerns, or requests regarding this Privacy Policy or how your medical data is handled within the AVO ecosystem, please contact us at:

* **Email:** `support@tylda.com`
* **Developer:** TYLDA / AVO Development Team
* **Location:** Egypt
