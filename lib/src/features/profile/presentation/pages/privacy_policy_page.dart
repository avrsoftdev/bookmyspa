import 'package:flutter/material.dart';
import '../../../../core/theme/tokens.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Introduction'),
            _buildSectionContent(
              'BookMySpa ("we", "our", or "us") operates the BookMySpa application. This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('2. Information Collection and Use'),
            _buildSectionContent(
              'We collect several different types of information for various purposes to provide and improve our Service to you.',
            ),
            _buildBulletPoint('Personal Data: Email address, name, phone number, address, and other profile information you voluntarily provide'),
            _buildBulletPoint('Usage Data: Browser type, IP address, pages visited, access times, and referring URL'),
            _buildBulletPoint('Location Data: Device location-based information with your consent'),
            _buildBulletPoint('Payment Data: Payment information processed through secure third-party payment processors'),
            const SizedBox(height: 24),
            _buildSectionTitle('3. Use of Data'),
            _buildSectionContent(
              'BookMySpa uses the collected data for various purposes:',
            ),
            _buildBulletPoint('To provide and maintain our Service'),
            _buildBulletPoint('To notify you about changes to our Service'),
            _buildBulletPoint('To provide customer support and respond to your requests'),
            _buildBulletPoint('To gather analysis or valuable information to enhance our Service'),
            _buildBulletPoint('To monitor the usage of our Service'),
            _buildBulletPoint('To detect, prevent and address technical issues and fraud'),
            const SizedBox(height: 24),
            _buildSectionTitle('4. Security of Data'),
            _buildSectionContent(
              'The security of your data is important to us but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('5. Service Providers'),
            _buildSectionContent(
              'We may employ third-party companies and individuals to facilitate our Service ("Service Providers"), to provide Service on our behalf, to perform Service-related services, or to assist us in analyzing how our Service is used. These third parties have access to your Personal Data only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('6. Links to Other Sites'),
            _buildSectionContent(
              'Our Service may contain links to other sites that are not operated by us. If you click on a third-party link, you will be directed to that third party\'s site. We strongly advise you to review the Privacy Policy of every site you visit. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('7. Children\'s Privacy'),
            _buildSectionContent(
              'Our Service does not address anyone under the age of 13 ("Children"). We do not knowingly collect personally identifiable information from anyone under the age of 13. If you are a parent or guardian and you are aware that your child has provided us with Personal Data, please contact us immediately.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('8. Changes to This Privacy Policy'),
            _buildSectionContent(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date at the bottom of this Privacy Policy.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('9. Contact Us'),
            _buildSectionContent(
              'If you have any questions about this Privacy Policy, please contact us at privacy@bookmyspa.com or support@bookmyspa.com.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('10. Data Retention'),
            _buildSectionContent(
              'We will retain your Personal Data only for as long as necessary for the purposes set out in this Privacy Policy. We will retain and use your Personal Data to the extent necessary to comply with our legal obligations (for example, if we are required to retain your data to comply with applicable laws), resolve disputes, and enforce our legal agreements and policies.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('11. Your Rights'),
            _buildSectionContent(
              'You have the right to access, update, or delete your personal information at any time by logging into your account or by contacting us. We will respond to your request within 30 days.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Last Updated: February 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
