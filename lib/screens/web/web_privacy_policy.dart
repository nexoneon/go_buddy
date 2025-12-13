import 'package:flutter/material.dart';
import '../../config/config.dart';

/// Web Privacy Policy Screen
///
/// Displays the privacy policy for 7 Pay Services
class WebPrivacyPolicyScreen extends StatelessWidget {
  const WebPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.privacy_tip_outlined,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '7 Pay Services',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last Updated: December 13, 2024',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 24),

                // Introduction
                _buildSection(
                  title: '1. Introduction',
                  content: '''
Welcome to 7 Pay Services. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and web services.

By using our services, you agree to the collection and use of information in accordance with this policy. If you do not agree with the terms of this privacy policy, please do not access the application.
''',
                ),

                _buildSection(
                  title: '2. Information We Collect',
                  content: '''
We collect information that you provide directly to us, including:

• **Personal Information**: Name, email address, phone number, and profile picture.
• **Account Information**: Login credentials and account preferences.
• **Transaction Data**: Order history, payment information, and delivery addresses.
• **Device Information**: Device type, operating system, and unique device identifiers.
• **Location Data**: With your consent, we may collect your location to provide location-based services.
• **Usage Data**: Information about how you use our app, including pages visited and features used.
''',
                ),

                _buildSection(
                  title: '3. How We Use Your Information',
                  content: '''
We use the information we collect for various purposes, including:

• To provide, maintain, and improve our services
• To process transactions and send related information
• To send you technical notices, updates, and support messages
• To respond to your comments, questions, and customer service requests
• To communicate with you about products, services, and promotional offers
• To monitor and analyze trends, usage, and activities
• To detect, investigate, and prevent fraudulent transactions and other illegal activities
• To personalize and improve your experience
''',
                ),

                _buildSection(
                  title: '4. Information Sharing',
                  content: '''
We may share your information in the following situations:

• **Service Providers**: We may share your information with third-party vendors who provide services on our behalf, such as payment processing, delivery services, and customer support.
• **Business Transfers**: In connection with any merger, sale of company assets, or acquisition, your information may be transferred.
• **Legal Requirements**: We may disclose your information if required to do so by law or in response to valid requests by public authorities.
• **With Your Consent**: We may share your information for other purposes with your explicit consent.

We do not sell, trade, or rent your personal identification information to others.
''',
                ),

                _buildSection(
                  title: '5. Data Security',
                  content: '''
We implement appropriate technical and organizational security measures to protect your personal information, including:

• Encryption of data in transit and at rest
• Regular security assessments and audits
• Access controls and authentication mechanisms
• Secure data storage with Firebase services

However, no method of transmission over the Internet or electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your personal information, we cannot guarantee its absolute security.
''',
                ),

                _buildSection(
                  title: '6. Your Rights',
                  content: '''
You have the following rights regarding your personal information:

• **Access**: You can request a copy of your personal data.
• **Correction**: You can request correction of inaccurate data.
• **Deletion**: You can request deletion of your personal data.
• **Portability**: You can request transfer of your data to another service.
• **Withdrawal of Consent**: You can withdraw consent for data processing at any time.

To exercise any of these rights, please contact us using the information provided at the end of this policy.
''',
                ),

                _buildSection(
                  title: '7. Cookies and Tracking',
                  content: '''
We use cookies and similar tracking technologies to:

• Remember your preferences and settings
• Analyze site traffic and usage
• Personalize content and advertisements
• Improve our services

You can control cookies through your browser settings. However, disabling cookies may limit your ability to use certain features of our services.
''',
                ),

                _buildSection(
                  title: '8. Third-Party Services',
                  content: '''
Our application may contain links to third-party websites or services that are not operated by us. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.

We encourage you to review the privacy policies of any third-party services you access through our application.
''',
                ),

                _buildSection(
                  title: '9. Children\'s Privacy',
                  content: '''
Our services are not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us so we can take appropriate action.
''',
                ),

                _buildSection(
                  title: '10. Changes to This Policy',
                  content: '''
We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.

You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.
''',
                ),

                _buildSection(
                  title: '11. Contact Us',
                  content: '''
If you have any questions about this Privacy Policy, please contact us:

**Email**: support@7payservices.com
**Phone**: +91 XXXXXXXXXX
**Address**: [Your Business Address]

We will respond to your inquiries within a reasonable timeframe.
''',
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                // Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        '© 2024 7 Pay Services. All rights reserved.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content.trim(),
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
