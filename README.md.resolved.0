# FixMyDiet

AI-powered virtual dietician and Ayurvedic consultant app designed for the Indian middle class.

## How to Build the APK via GitHub Actions

This repository is set up with a GitHub Actions workflow that will automatically build your Android APK file. Follow these steps to trigger the build and get your APK:

### 1. Setup Firebase
Since this app uses Firebase Authentication and Firestore, you need a `google-services.json` file.
1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (e.g., "FixMyDiet")
3. Enable **Authentication** (Email/Password & Google)
4. Enable **Firestore Database** (Start in test mode or set appropriate security rules)
5. Add an Android App to your Firebase project. Package name: `com.antigravity.fix_my_diet`
6. Download the `google-services.json` file.

### 2. Add Secrets to GitHub
The automated build needs your Firebase configuration to work.
1. Open your terminal or a Base64 converter tool.
2. Convert your `google-services.json` into a base64 string. 
   - **Windows (PowerShell):** `[convert]::ToBase64String([IO.File]::ReadAllBytes("google-services.json")) | clip`
   - **Mac/Linux:** `base64 -i google-services.json | pbcopy`
3. Go to your GitHub Repository -> **Settings** -> **Secrets and variables** -> **Actions** -> **New repository secret**.
4. Name the secret **`GOOGLE_SERVICES_JSON`**
5. Paste the base64 string as the value.

### 3. Build the APK
1. Go to the **Actions** tab in your GitHub repository.
2. Click on the **"Build Flutter APK"** workflow on the left side.
3. Click the **"Run workflow"** button.
4. Wait for the build to finish (usually takes 3-5 minutes).
5. Once completed, scroll to the bottom of the workflow run summary to find the **Artifacts** section.
6. Download the `FixMyDiet-APK.zip` file, extract it, and install `app-release.apk` on your physical Android device.

## Note on Gemini API Key
The Gemini API key is currently hardcoded in `lib/core/constants/app_constants.dart` for testing purposes based on your provided key. For a production release, it's recommended to move this to a secure environment variable or fetch it securely from Firebase Remote Config.
