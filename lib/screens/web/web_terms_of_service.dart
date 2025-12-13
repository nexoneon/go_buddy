import 'package:flutter/material.dart';
import '../../config/config.dart';

/// Web Terms of Service Screen
///
/// Displays the terms of service for 7 Pay Services
class WebTermsOfServiceScreen extends StatelessWidget {
  const WebTermsOfServiceScreen({super.key});

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
          'Terms of Service',
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
                          Icons.gavel_outlined,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Terms of Service',
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

                // Agreement to Terms
                _buildSection(
                  title: '1. Agreement to Terms',
                  content: '''
By accessing or using the 7 Pay Services application ("App") and related services ("Services"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, please do not use our Services.

These Terms apply to all visitors, users, and others who wish to access or use the Services. By using the Services, you represent that you are at least 18 years of age or have the consent of a parent or guardian.
''',
                ),

                _buildSection(
                  title: '2. Description of Services',
                  content: '''
7 Pay Services provides a platform for:

• **Service Booking**: Browse and book various services offered through our platform
• **Order Management**: Track and manage your service orders
• **Payment Processing**: Secure payment processing for services
• **Delivery Tracking**: Real-time tracking of service delivery
• **Customer Support**: Access to customer support for service-related inquiries

We reserve the right to modify, suspend, or discontinue any part of the Services at any time without prior notice.
''',
                ),

                _buildSection(
                  title: '3. User Accounts',
                  content: '''
To access certain features of the Services, you must create an account. When creating an account, you agree to:

• Provide accurate, current, and complete information
• Maintain the security of your account credentials
• Promptly update any changes to your information
• Accept responsibility for all activities under your account
• Notify us immediately of any unauthorized access

We reserve the right to suspend or terminate accounts that violate these Terms or engage in fraudulent activity.
''',
                ),

                _buildSection(
                  title: '4. User Responsibilities',
                  content: '''
As a user of our Services, you agree to:

• Use the Services only for lawful purposes
• Not engage in any activity that disrupts or interferes with the Services
• Not attempt to gain unauthorized access to any part of the Services
• Not use the Services to transmit harmful, offensive, or illegal content
• Comply with all applicable laws and regulations
• Respect the intellectual property rights of others
• Not copy, modify, or distribute our content without permission
''',
                ),

                _buildSection(
                  title: '5. Orders and Payments',
                  content: '''
When placing orders through our Services:

• **Pricing**: All prices are displayed in Indian Rupees (INR) and include applicable taxes unless otherwise stated
• **Payment**: Payment is required at the time of order placement unless alternate arrangements are specified
• **Confirmation**: Orders are confirmed only after successful payment processing
• **Cancellation**: Cancellation policies vary by service type and are displayed at the time of booking
• **Refunds**: Refund eligibility depends on the specific service and timing of cancellation

We reserve the right to refuse or cancel orders at our discretion, and we will notify you if this occurs.
''',
                ),

                _buildSection(
                  title: '6. Service Delivery',
                  content: '''
Regarding service delivery:

• We strive to deliver services within the estimated timeframes provided
• Delivery times are estimates and may vary based on circumstances
• We are not liable for delays caused by factors beyond our control
• You agree to be available to receive services at the scheduled time
• Failure to be available may result in additional charges or order cancellation

Service providers are independent contractors and not employees of 7 Pay Services.
''',
                ),

                _buildSection(
                  title: '7. Intellectual Property',
                  content: '''
All content, features, and functionality of the Services, including but not limited to:

• Software, text, graphics, logos, and images
• Audio, video, and other multimedia content
• Trademarks, service marks, and trade names

are owned by 7 Pay Services or its licensors and are protected by intellectual property laws. You may not reproduce, distribute, modify, or create derivative works without our explicit written permission.
''',
                ),

                _buildSection(
                  title: '8. Limitation of Liability',
                  content: '''
To the maximum extent permitted by law:

• The Services are provided "as is" without warranties of any kind
• We do not guarantee uninterrupted or error-free operation
• We are not liable for any indirect, incidental, or consequential damages
• Our total liability shall not exceed the amount paid by you for the specific service in question
• We are not responsible for the actions or omissions of third-party service providers

You agree to use the Services at your own risk.
''',
                ),

                _buildSection(
                  title: '9. Indemnification',
                  content: '''
You agree to indemnify, defend, and hold harmless 7 Pay Services, its officers, directors, employees, and agents from any claims, damages, losses, or expenses (including legal fees) arising from:

• Your use of the Services
• Your violation of these Terms
• Your violation of any third-party rights
• Any content you submit through the Services
''',
                ),

                _buildSection(
                  title: '10. Dispute Resolution',
                  content: '''
Any disputes arising from these Terms or the Services shall be:

• First attempted to be resolved through informal negotiation
• If unresolved, submitted to binding arbitration
• Governed by the laws of India
• Subject to the exclusive jurisdiction of courts in [Your City], India

You agree to waive any right to participate in class action lawsuits against us.
''',
                ),

                _buildSection(
                  title: '11. Termination',
                  content: '''
We may terminate or suspend your access to the Services immediately, without prior notice, if:

• You breach any provision of these Terms
• We are required to do so by law
• We discontinue the Services

Upon termination, your right to use the Services ceases immediately. Provisions that by their nature should survive termination shall remain in effect.
''',
                ),

                _buildSection(
                  title: '12. Changes to Terms',
                  content: '''
We reserve the right to modify these Terms at any time. Changes will be effective when posted on the App or website. Your continued use of the Services after changes are posted constitutes acceptance of the modified Terms.

We encourage you to review these Terms periodically for updates.
''',
                ),

                _buildSection(
                  title: '13. Severability',
                  content: '''
If any provision of these Terms is found to be invalid or unenforceable, the remaining provisions shall continue in full force and effect. The invalid provision shall be modified to the minimum extent necessary to make it valid and enforceable.
''',
                ),

                _buildSection(
                  title: '14. Contact Information',
                  content: '''
For questions about these Terms of Service, please contact us:

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
                      const SizedBox(height: 8),
                      Text(
                        'By using our services, you agree to these terms.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
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
