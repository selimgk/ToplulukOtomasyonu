import 'package:flutter/material.dart';
import 'package:derss1/models.dart';
import 'package:derss1/database_helper.dart';
import 'package:derss1/widgets/common_app_bar.dart';

class CommunityDetailScreen extends StatefulWidget {
  final Community community;
  final String? username;
  final String? studentNumber;

  const CommunityDetailScreen({
    super.key, 
    required this.community,
    this.username,
    this.studentNumber,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  bool _isLoading = true;
  bool _isMember = false; // Is member of THIS community
  bool _hasOtherMembership = false; // Is member of ANY community


  @override
  void initState() {
    super.initState();
    _checkMembership();
  }

  Future<void> _checkMembership() async {
    if (widget.studentNumber == null) {
      setState(() => _isLoading = false);
      return;
    }

    final membership = await DatabaseHelper.instance.getMembership(widget.studentNumber!);
    
    if (mounted) {
      setState(() {
        if (membership != null) {
          _hasOtherMembership = true;
          if (membership['community_id'] == widget.community.id) {
            _isMember = true;
          }
           // Fetch name of the community they are member of if needed, 
           // but for now just knowing they have one is enough to block.
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _joinCommunity() async {
    if (widget.studentNumber == null || widget.username == null) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseHelper.instance.addMembership(
        widget.studentNumber!,
        widget.username!,
        widget.community.id!,
      );
      
      // Update local state
      await _checkMembership();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Topluluğa başarıyla üye oldunuz!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Üyelik işlemi başarısız: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveCommunity() async {
    if (widget.studentNumber == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Topluluktan Ayrıl'),
        content: const Text('Bu topluluktan ayrılmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ayrıl'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseHelper.instance.deleteMembership(widget.studentNumber!);
      
      // Update local state
      await _checkMembership();
       
      if (mounted) {
         setState(() {
           _isMember = false;
           _hasOtherMembership = false;
         });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Topluluktan ayrıldınız.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İşlem başarısız: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: widget.community.name, showHome: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image (or Placeholder)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade100, width: 4),
                ),
                child: (widget.community.image != null && widget.community.image!.isNotEmpty)
                    ? ClipOval(
                        child: widget.community.image!.startsWith('assets/')
                            ? Image.asset(
                                widget.community.image!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                widget.community.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Image.asset(
                                  'assets/images/uludag_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                      )
                    : ClipOval(
                        child: Image.asset(
                          'assets/images/uludag_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Name
            Text(
              widget.community.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 48),

            // Membership Action Section
            if (widget.studentNumber != null) ...[
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_isMember)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 48),
                        const SizedBox(height: 8),
                        const Text(
                          'Bu Topluluğun Üyesisiniz',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _leaveCommunity,
                          icon: const Icon(Icons.exit_to_app, color: Colors.red),
                          label: const Text('Topluluktan Ayrıl', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_hasOtherMembership)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Zaten başka bir topluluğa üyesiniz.',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _joinCommunity,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Topluluğa Üye Ol'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                const Divider(height: 48),
            ],

            // Info Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(Icons.person, 'Başkan', widget.community.president ?? 'Belirtilmedi'),
                _buildStatItem(Icons.groups, 'Üye Sayısı', '${widget.community.memberCount}'),
              ],
            ),
            const Divider(height: 48),

            // Description
            const Text(
              'Topluluk Hakkında',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.community.description,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
