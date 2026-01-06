---
description: How to release the app on Google Play Store
---

# Google Play Store Release Guide for 7 Pay Services (Go Buddy)

## 📦 Build Files Generated

Your app has been successfully built! The following release files are ready:

- **APK (Direct Install)**: `build\app\outputs\flutter-apk\app-release.apk` (52.3MB)
- **AAB (Google Play)**: `build\app\outputs\bundle\release\app-release.aab` (44.1MB)

### App Details
- **Package Name**: `app.sevenpayservice.gobuddy`
- **App Name**: 7 Pay Services
- **Version**: 1.0.0 (Build 1)
- **Target SDK**: 36 (Android 16)
- **Min SDK**: 21 (Android 5.0)

---

## 🚀 Step-by-Step Google Play Store Release

### Phase 1: Google Play Console Setup

#### 1. Create Google Play Console Account
- Go to [Google Play Console](https://play.google.com/console)
- Sign in with a Google Account (preferably `jayaprakeshnarayana7@gmail.com` or company account)
- Pay the **one-time $25 registration fee** (required for first-time developers)

#### 2. Create New App
- Click **"Create app"**
- Fill in the required details:
  - **App name**: `7 Pay Services` (or your preferred name)
  - **Default language**: English (United States)
  - **App or Game**: App
  - **Free or Paid**: Free
  - Accept the Developer Program Policies and US export laws

#### 3. Complete App Details

Navigate to **"Dashboard"** and complete the following sections:

##### A. App Access
- If your app requires login, provide test credentials
- Otherwise, mark "All functionality is available without special access"

##### B. Ads
- Select whether your app contains ads (Yes/No)

##### C. Content Rating
- Complete the content rating questionnaire
- This determines age restrictions (ESRB, PEGI, etc.)

##### D. Target Audience
- Select age groups (e.g., 18+)
- Indicate if the app is designed for children

##### E. News App
- Indicate if this is a news app (No)

##### F. COVID-19 Contact Tracing
- Indicate if this is a COVID-19 contact tracing app (No)

##### G. Data Safety
- Fill out the data safety form
- Based on your app:
  - **Data collected**: Phone number, Name, Profile photo (optional), Location (for service requests)
  - **Data usage**: Account creation, Service delivery, Authentication
  - **Data sharing**: Firebase Authentication, Firestore
  - **Security practices**: Data encrypted in transit, Users can request data deletion

##### H. Government Apps
- Indicate if this is a government app (No)

### Phase 2: Store Listing

Navigate to **"Store listing"** under the **"Grow"** section:

#### 1. App Details
- **App name**: `7 Pay Services`
- **Short description** (80 chars max):
  ```
  On-demand services at your doorstep. Book trusted professionals instantly.
  ```
- **Full description** (4000 chars max):
  ```
  7 Pay Services - Your Trusted Service Partner
  
  Looking for reliable home services? 7 Pay Services connects you with verified professionals for all your needs.
  
  🏠 SERVICES WE OFFER:
  • Home Cleaning & Maintenance
  • Plumbing & Electrical Work
  • Appliance Repair
  • Carpentry & Painting
  • AC Service & Repair
  • And many more!
  
  ✨ WHY CHOOSE US:
  • Verified Professionals
  • Instant Booking
  • Transparent Pricing
  • Secure Payments
  • 24/7 Customer Support
  • Real-time Tracking
  
  📱 HOW IT WORKS:
  1. Browse Services - Choose from our wide range of services
  2. Book Instantly - Select date and time that works for you
  3. Track Professional - Get real-time updates
  4. Rate & Review - Share your experience
  
  🔒 SAFE & SECURE:
  • Background-verified professionals
  • Secure online payments
  • Privacy-first approach
  • Data encryption
  
  Download 7 Pay Services now and experience hassle-free home services!
  
  For support, visit: https://sevenpayservices.com
  ```

#### 2. App Icon & Screenshots
- **App icon**: Already configured (512x512 PNG)
- **Screenshots** (Required):
  - **Phone screenshots**: Minimum 2 images (1080x1920 or 1080x2400)
  - **7-inch tablet screenshots**: Optional but recommended
  - **10-inch tablet screenshots**: Optional but recommended
  
  **Note**: You'll need to create screenshots of your app. Use an Android emulator or physical device.

#### 3. Feature Graphic
- Required image: 1024x500 PNG or JPEG
- Use this for the banner on the Play Store

#### 4. Contact Details
- **Email**: `jayaprakeshnarayana7@gmail.com` (or your support email)
- **Phone**: Optional
- **Website**: `https://sevenpayservices.com`

#### 5. Privacy Policy
- **URL**: `https://sevenpayservices.com/privacy-policy-2/`

#### 6. Category
- **App category**: Business (or Lifestyle)
- **Tags**: Services, Home Services, On-Demand

### Phase 3: Upload App Bundle

#### 1. Navigate to Production Track
- Go to **"Release"** → **"Production"**
- Click **"Create new release"**

#### 2. Upload AAB
- Click **"Upload"**
- Select: `build\app\outputs\bundle\release\app-release.aab`
- Wait for upload and processing (Google Play will validate your bundle)

#### 3. Release Notes
Add release notes for version 1.0.0:
```
🎉 Welcome to 7 Pay Services!

Initial release featuring:
• Browse and book 50+ home services
• Easy phone-based authentication
• Real-time service tracking
• Secure payment integration
• User favorites and service history
• 24/7 customer support

We're excited to serve you!
```

#### 4. Review Release
- Verify app details
- Check rollout percentage (start with 100% for initial release)
- Review pre-launch report (if available)

#### 5. Start Rollout
- Click **"Save"** then **"Review release"**
- Click **"Start rollout to Production"**

### Phase 4: Post-Submission

#### 1. Review Process
- Google typically reviews within **1-3 business days**
- You'll receive email notifications at each stage
- Watch for any policy violations or technical issues

#### 2. Common Reasons for Rejection
- Missing privacy policy
- Incomplete data safety form
- Content policy violations
- Technical issues (crashes, broken features)
- Misleading content or screenshots

#### 3. Once Approved
- Your app will appear on Google Play Store
- Share the link: `https://play.google.com/store/apps/details?id=app.sevenpayservice.gobuddy`

---

## 🔄 Future Updates

When you need to release an update:

### 1. Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.1+2  # Increment version name and build number
```

### 2. Build New AAB
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### 3. Upload to Play Console
- Go to **"Release"** → **"Production"**
- Create new release
- Upload new AAB
- Add release notes
- Submit for review

---

## 📊 Analytics & Monitoring

### Set Up Google Analytics (Optional)
1. Create Firebase Analytics in your Firebase project
2. Add `firebase_analytics` to `pubspec.yaml`
3. Track user events and app performance

### Monitor Crashes
- Firebase Crashlytics is recommended
- Add `firebase_crashlytics` to your project
- Monitor real-time crash reports

---

## 🎨 Marketing Materials Needed

Before submission, prepare:

1. **Screenshots** (2-8 images):
   - Home screen
   - Service listing
   - Service details
   - Booking flow
   - Profile screen
   - Payment screen

2. **Feature Graphic** (1024x500):
   - Banner showcasing your app

3. **App Icon** (512x512):
   - Already configured ✅

4. **Promotional Video** (Optional):
   - YouTube video demonstrating your app

---

## ✅ Pre-Launch Checklist

- [ ] Google Play Console account created
- [ ] One-time $25 fee paid
- [ ] App created in Play Console
- [ ] Store listing completed
- [ ] Screenshots uploaded (minimum 2)
- [ ] Feature graphic uploaded
- [ ] Privacy policy URL added
- [ ] Data safety form completed
- [ ] Content rating completed
- [ ] AAB file uploaded
- [ ] Release notes added
- [ ] Test credentials provided (if required)
- [ ] All required sections marked as "Done"

---

## 🆘 Support & Resources

- **Google Play Console**: https://play.google.com/console
- **Play Console Help**: https://support.google.com/googleplay/android-developer
- **Policy Center**: https://play.google.com/about/developer-content-policy/
- **Firebase Console**: https://console.firebase.google.com/project/payservices-7827a

---

## 📝 Notes

- Initial review can take **1-7 days**
- Updates typically review faster (1-3 days)
- Always test thoroughly before submission
- Keep your keystore file (`upload-keystore.jks`) and `key.properties` **SAFE** - losing it means you can't update your app!
- Consider staged rollouts for major updates (start with 10-20% of users)

---

**Good luck with your Google Play Store release! 🚀**
