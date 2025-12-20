import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../models/about_us_model.dart';
import '../../models/faq_model.dart';
import '../../models/support_model.dart';
import '../../services/about_us_service.dart';
import '../../services/faq_service.dart';
import '../../services/support_service.dart';

/// Mobile Help Screen
///
/// Displays About Us, FAQ, and Support information for mobile users
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AboutUsService _aboutUsService = AboutUsService();
  final FAQService _faqService = FAQService();
  final SupportService _supportService = SupportService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar Header
        Container(
          color: AppTheme.primaryColor,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'About Us', icon: Icon(Icons.info_outline, size: 20)),
              Tab(text: 'FAQ', icon: Icon(Icons.help_outline, size: 20)),
              Tab(text: 'Support', icon: Icon(Icons.support_agent, size: 20)),
            ],
          ),
        ),
        // Body
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildAboutUsTab(), _buildFAQTab(), _buildSupportTab()],
          ),
        ),
      ],
    );
  }

  // ============== ABOUT US TAB ==============
  Widget _buildAboutUsTab() {
    return StreamBuilder<List<AboutUsModel>>(
      stream: _aboutUsService.getAboutUsItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error loading About Us');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _buildEmptyState(
            icon: Icons.article_outlined,
            title: 'No information available',
            subtitle: 'About Us content will appear here',
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildAboutUsCard(item, index);
          },
        );
      },
    );
  }

  Widget _buildAboutUsCard(AboutUsModel item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withAlpha(200),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.header,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============== FAQ TAB ==============
  Widget _buildFAQTab() {
    return StreamBuilder<List<FAQModel>>(
      stream: _faqService.getFAQItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error loading FAQs');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _buildEmptyState(
            icon: Icons.quiz_outlined,
            title: 'No FAQs available',
            subtitle: 'Frequently asked questions will appear here',
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildFAQCard(item, index);
          },
        );
      },
    );
  }

  Widget _buildFAQCard(FAQModel item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            item.question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.primaryColor,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.answer,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== SUPPORT TAB ==============
  Widget _buildSupportTab() {
    return StreamBuilder<List<SupportModel>>(
      stream: _supportService.getSupportItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error loading Support info');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _buildEmptyState(
            icon: Icons.contact_support_outlined,
            title: 'No support information',
            subtitle: 'Contact details will appear here',
          );
        }

        // Group items by type
        final contactItems = items
            .where((i) => i.type.toLowerCase() == 'contact')
            .toList();
        final hoursItems = items
            .where((i) => i.type.toLowerCase() == 'hours')
            .toList();
        final addressItems = items
            .where((i) => i.type.toLowerCase() == 'address')
            .toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contactItems.isNotEmpty) ...[
                _buildSectionHeader('Contact Us', Icons.phone, Colors.green),
                const SizedBox(height: 12),
                ...contactItems.map((item) => _buildSupportCard(item)),
              ],
              if (hoursItems.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Support Hours',
                  Icons.access_time,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                ...hoursItems.map((item) => _buildSupportCard(item)),
              ],
              if (addressItems.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Our Location',
                  Icons.location_on,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                ...addressItems.map((item) => _buildSupportCard(item)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSupportCard(SupportModel item) {
    final color = _getSupportTypeColor(item.type);
    final icon = _getSupportTypeIcon(item.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSupportTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'contact':
        return Colors.green;
      case 'hours':
        return Colors.orange;
      case 'address':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getSupportTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'contact':
        return Icons.phone;
      case 'hours':
        return Icons.access_time;
      case 'address':
        return Icons.location_on;
      default:
        return Icons.info;
    }
  }

  // ============== HELPER WIDGETS ==============
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
