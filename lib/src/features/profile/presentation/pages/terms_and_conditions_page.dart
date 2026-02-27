import 'package:flutter/material.dart';
import '../../../../core/theme/tokens.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Acceptance of Terms'),
            _buildSectionContent(
              'By accessing and using BookMySpa, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('2. Use License'),
            _buildSectionContent(
              'Permission is granted to temporarily download one copy of the materials (information or software) on BookMySpa for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:',
            ),
            _buildBulletPoint('Modifying or copying the materials'),
            _buildBulletPoint('Using the materials for any commercial purpose or for any public display'),
            _buildBulletPoint('Attempting to decompile or reverse engineer any software contained on BookMySpa'),
            _buildBulletPoint('Removing any copyright or other proprietary notations from the materials'),
            _buildBulletPoint('Transferring the materials to another person or "mirroring" the materials on any other server'),
            const SizedBox(height: 24),
            _buildSectionTitle('3. Disclaimer'),
            _buildSectionContent(
              'The materials on BookMySpa are provided on an \'as is\' basis. BookMySpa makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('4. Limitations'),
            _buildSectionContent(
              'In no event shall BookMySpa or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on BookMySpa, even if BookMySpa or an authorized representative has been notified orally or in writing of the possibility of such damage.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('5. Accuracy of Materials'),
            _buildSectionContent(
              'The materials appearing on BookMySpa could include technical, typographical, or photographic errors. BookMySpa does not warrant that any of the materials on its website are accurate, complete, or current. BookMySpa may make changes to the materials contained on its website at any time without notice.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('6. Links'),
            _buildSectionContent(
              'BookMySpa has not reviewed all of the sites linked to its website and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by BookMySpa of the site. Use of any such linked website is at the user\'s own risk.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('7. Modifications'),
            _buildSectionContent(
              'BookMySpa may revise these terms of service for its website at any time without notice. By using this website, you are agreeing to be bound by the then current version of these terms of service.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('8. Governing Law'),
            _buildSectionContent(
              'These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction in which BookMySpa operates, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('9. Contact Information'),
            _buildSectionContent(
              'If you have any questions about these Terms and Conditions, please contact us at support@bookmyspa.com.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? AppColors.darkTextPrimary : Colors.black87,
          ),
        );
      },
    );
  }

  Widget _buildSectionContent(String content) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? AppColors.darkTextSecondary : Colors.black54,
              height: 1.6,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? AppColors.darkTextSecondary : Colors.black54;
        return Padding(
          padding: const EdgeInsets.only(top: 8, left: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
