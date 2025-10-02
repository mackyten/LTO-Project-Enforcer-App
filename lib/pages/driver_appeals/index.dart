import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../shared/app_theme/colors.dart';
import '../../shared/app_theme/fonts.dart';
import '../../shared/decorations/app_bg.dart';
import '../../utils/date_formatter.dart';
import '../appeal/models/appeal_model.dart';
import 'handlers.dart';

class DriverAppealsPage extends StatefulWidget {
  const DriverAppealsPage({super.key});

  @override
  State<DriverAppealsPage> createState() => _DriverAppealsPageState();
}

class _DriverAppealsPageState extends State<DriverAppealsPage> {
  final ScrollController _scrollController = ScrollController();
  final DriverAppealsHandlers _handlers = DriverAppealsHandlers();
  final List<AppealModel> _appeals = [];
  
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isInitialLoad = true;
  final int _pageSize = 10;
  
  Map<String, int> _statusCounts = {
    'Pending': 0,
    'Approved': 0,
    'Rejected': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadAppeals();
    _loadStatusCounts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMoreData) {
      _loadMoreAppeals();
    }
  }

  Future<void> _loadStatusCounts() async {
    try {
      final counts = await _handlers.getAppealsCountByStatus();
      setState(() {
        _statusCounts = counts;
      });
    } catch (e) {
      print('Error loading status counts: $e');
    }
  }

  Future<void> _loadAppeals() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _handlers.getDriverAppeals(limit: _pageSize);

      if (snapshot.docs.isNotEmpty) {
        final List<AppealModel> newAppeals = snapshot.docs
            .map((doc) => AppealModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList();

        setState(() {
          _appeals.clear();
          _appeals.addAll(newAppeals);
          _lastDocument = snapshot.docs.last;
          _hasMoreData = snapshot.docs.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading appeals: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isInitialLoad = false;
      });
    }
  }

  Future<void> _loadMoreAppeals() async {
    if (_isLoading || !_hasMoreData || _lastDocument == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _handlers.getDriverAppeals(
        lastDocument: _lastDocument,
        limit: _pageSize,
      );

      if (snapshot.docs.isNotEmpty) {
        final List<AppealModel> newAppeals = snapshot.docs
            .map((doc) => AppealModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList();

        setState(() {
          _appeals.addAll(newAppeals);
          _lastDocument = snapshot.docs.last;
          _hasMoreData = snapshot.docs.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading more appeals: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAppeals() async {
    setState(() {
      _appeals.clear();
      _lastDocument = null;
      _hasMoreData = true;
    });
    await _loadAppeals();
    await _loadStatusCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor().primary,
        foregroundColor: Colors.white,
        title: Text(
          'My Appeals',
          style: TextStyle(
            fontSize: FontSizes().h3,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appBg,
        child: Column(
          children: [
            // Status Summary Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Appeal Status Overview',
                        style: TextStyle(
                          fontSize: FontSizes().h4,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          'Pending',
                          _statusCounts['pending'] ?? 0,
                          Colors.orange,
                          Icons.access_time,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          'Approved',
                          _statusCounts['approved'] ?? 0,
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          'Rejected',
                          _statusCounts['rejected'] ?? 0,
                          Colors.red,
                          Icons.cancel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Appeals List
            Expanded(
              child: _isInitialLoad
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Loading appeals...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: FontSizes().body,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _appeals.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshAppeals,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _appeals.length + (_hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _appeals.length) {
                            return _buildLoadingIndicator();
                          }
                          return _buildAppealCard(_appeals[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/appeal');
        },
        backgroundColor: MainColor().primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('New Appeal'),
      ),
    );
  }

  Widget _buildStatusCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: FontSizes().h3,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: FontSizes().caption,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gavel,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              'No Appeals Found',
              style: TextStyle(
                fontSize: FontSizes().h3,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'You haven\'t submitted any appeals yet. If you believe a violation was issued in error, you can file an appeal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontSizes().body,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/appeal');
              },
              icon: Icon(Icons.add),
              label: Text('File New Appeal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MainColor().primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildAppealCard(AppealModel appeal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showAppealDetails(appeal),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appeal.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getStatusIcon(appeal.status),
                          color: _getStatusColor(appeal.status),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appeal.violationTrackingNumber,
                              style: TextStyle(
                                fontSize: FontSizes().h4,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              appeal.reasonForAppeal.length > 100
                                  ? '${appeal.reasonForAppeal.substring(0, 100)}...'
                                  : appeal.reasonForAppeal,
                              style: TextStyle(
                                fontSize: FontSizes().body,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  DateFormatter.format(appeal.createdAt),
                                  style: TextStyle(
                                    fontSize: FontSizes().caption,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appeal.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(appeal.status).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          appeal.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: FontSizes().caption,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(appeal.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _showAppealDetails(AppealModel appeal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: MainColor().secondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appeal.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getStatusIcon(appeal.status),
                            color: _getStatusColor(appeal.status),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appeal Details',
                                style: TextStyle(
                                  fontSize: FontSizes().h3,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                appeal.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: FontSizes().body,
                                  color: _getStatusColor(appeal.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    _buildDetailRow('Violation Tracking Number', appeal.violationTrackingNumber),
                    _buildDetailRow('Date Submitted', DateFormatter.format(appeal.createdAt)),
                    
                    SizedBox(height: 16),
                    Text(
                      'Reason for Appeal',
                      style: TextStyle(
                        fontSize: FontSizes().body,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appeal.reasonForAppeal,
                        style: TextStyle(
                          fontSize: FontSizes().body,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),

                    if (appeal.uploadedDocuments.isNotEmpty || appeal.supportingDocuments.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Text(
                        'Attached Documents',
                        style: TextStyle(
                          fontSize: FontSizes().body,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Documents: ${appeal.uploadedDocuments.length + appeal.supportingDocuments.length} file(s)',
                        style: TextStyle(
                          fontSize: FontSizes().caption,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],

                    Spacer(),
                    
                    if (appeal.status == 'pending')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeleteConfirmation(appeal),
                          icon: Icon(Icons.delete),
                          label: Text('Delete Appeal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: FontSizes().body,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSizes().body,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(AppealModel appeal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Appeal'),
        content: Text(
          'Are you sure you want to delete this appeal? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              Navigator.pop(context); // Close details modal
              
              try {
                await _handlers.deleteAppeal(appeal.id!);
                await _refreshAppeals();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Appeal deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting appeal: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
