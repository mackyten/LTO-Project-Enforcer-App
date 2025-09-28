import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enforcer_auto_fine/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/app_theme/colors.dart';
import '../../shared/app_theme/fonts.dart';
import '../../shared/decorations/app_bg.dart';
import '../../pages/violation/models/report_model.dart';

class DriverViolationsPage extends StatefulWidget {
  final String plateNumber;

  const DriverViolationsPage({super.key, required this.plateNumber});

  @override
  State<DriverViolationsPage> createState() => _DriverViolationsPageState();
}

class _DriverViolationsPageState extends State<DriverViolationsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<ReportModel> _violations = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isInitialLoad = true;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadViolations();
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
      _loadMoreViolations();
    }
  }

  Future<void> _loadViolations() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('reports')
          .where('plateNumber', isEqualTo: widget.plateNumber)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final List<ReportModel> newViolations = snapshot.docs
            .map(
              (doc) => ReportModel.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList();

        setState(() {
          _violations.clear();
          _violations.addAll(newViolations);
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
            content: Text('Error loading violations: $e'),
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

  Future<void> _loadMoreViolations() async {
    if (_isLoading || !_hasMoreData || _lastDocument == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('reports')
          .where('plateNumber', isEqualTo: widget.plateNumber)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize);

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final List<ReportModel> newViolations = snapshot.docs
            .map(
              (doc) => ReportModel.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList();

        setState(() {
          _violations.addAll(newViolations);
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
            content: Text('Error loading more violations: $e'),
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

  Future<void> _refreshViolations() async {
    setState(() {
      _violations.clear();
      _lastDocument = null;
      _hasMoreData = true;
    });
    await _loadViolations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor().primary,
        foregroundColor: Colors.white,
        title: Text(
          'My Violations',
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
            // Header Info Section
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
                      Icon(Icons.directions_car, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Vehicle: ${widget.plateNumber}',
                        style: TextStyle(
                          fontSize: FontSizes().h4,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total Violations: ${_violations.length}${_hasMoreData ? '+' : ''}',
                    style: TextStyle(
                      fontSize: FontSizes().body,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Violations List
            Expanded(
              child: _isInitialLoad
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Loading violations...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: FontSizes().body,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _violations.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshViolations,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _violations.length + (_hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _violations.length) {
                            return _buildLoadingIndicator();
                          }
                          return _buildViolationCard(_violations[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
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
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green.withOpacity(0.7),
            ),
            SizedBox(height: 24),
            Text(
              'No Violations Found',
              style: TextStyle(
                fontSize: FontSizes().h3,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Great news! You have no traffic violations on record for vehicle ${widget.plateNumber}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontSizes().body,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshViolations,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
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

  Widget _buildViolationCard(ReportModel violation) {
    String primaryViolation = violation.violations.isNotEmpty
        ? violation.violations.first.violationName
        : 'Traffic Violation';

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
            onTap: () => _showViolationDetails(violation),
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
                          color: _getViolationColor(
                            primaryViolation,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getViolationIcon(primaryViolation),
                          color: _getViolationColor(primaryViolation),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              primaryViolation,
                              style: TextStyle(
                                fontSize: FontSizes().h4,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              violation.address,
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
                                  _formatDate(violation.createdAt),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              'PENDING',
                              style: TextStyle(
                                fontSize: FontSizes().caption,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            violation.trackingNumber ?? 'N/A',
                            style: TextStyle(
                              fontSize: FontSizes().caption,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (violation.violations.length > 1) ...[
                    SizedBox(height: 12),
                    Text(
                      '+${violation.violations.length - 1} more violation${violation.violations.length > 2 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: FontSizes().caption,
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showViolationDetails(ReportModel violation) {
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
                            color: _getViolationColor(
                              violation.violations.first.violationName,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getViolationIcon(violation.violations.first.violationName),
                            color: _getViolationColor(
                              violation.violations.first.violationName,
                            ),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                              'Traffic Violation Report',
                              style: TextStyle(
                                fontSize: FontSizes().h3,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              ),
                              Row(
                              children: [
                                Expanded(
                                child: Text(
                                  violation.trackingNumber ??
                                    'No tracking number',
                                  style: TextStyle(
                                  fontSize: FontSizes().body,
                                  color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                ),
                                if (violation.trackingNumber != null)
                                IconButton(
                                  onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                    text: violation.trackingNumber!,
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                    content: Text('Tracking number copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                    ),
                                  );
                                  },
                                  icon: Icon(
                                  Icons.copy,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildDetailRow('Driver Name', violation.fullname),
                    _buildDetailRow('Address', violation.address),
                    _buildDetailRow('Phone Number', violation.phoneNumber),
                    _buildDetailRow('License Number', violation.licenseNumber),
                    _buildDetailRow('Plate Number', violation.plateNumber),
                    _buildDetailRow(
                      'Date & Time',
                      DateFormatter.format(violation.createdAt!),
                    ),

                    SizedBox(height: 16),
                    Text(
                      'Violations',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: violation.violations
                            .map(
                              (v) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.fiber_manual_record,
                                      size: 8,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            v.violationName,
                                            style: TextStyle(
                                              fontSize: FontSizes().body,
                                              color: Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                'Fine: ₱${v.price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: FontSizes().caption,
                                                  color: Colors.white.withOpacity(0.6),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _getOffenseColor(v.repetition).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: _getOffenseColor(v.repetition).withOpacity(0.5),
                                                  ),
                                                ),
                                                child: Text(
                                                  _getOrdinalNumber(v.repetition),
                                                  style: TextStyle(
                                                    fontSize: FontSizes().caption,
                                                    color: _getOffenseColor(v.repetition).withOpacity(0.9),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context, 
                            '/appeal', 
                            arguments: violation.trackingNumber,
                          );
                        },
                        icon: Icon(Icons.gavel),
                        label: Text('File an Appeal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
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

  Color _getViolationColor(String violationType) {
    switch (violationType.toLowerCase()) {
      case 'speeding':
        return Colors.red;
      case 'parking violation':
        return Colors.orange;
      case 'traffic light violation':
        return Colors.amber;
      case 'no helmet':
        return Colors.purple;
      case 'reckless driving':
        return Colors.deepOrange;
      case 'no license':
        return Colors.red;
      case 'expired registration':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getViolationIcon(String violationType) {
    switch (violationType.toLowerCase()) {
      case 'speeding':
        return Icons.speed;
      case 'parking violation':
        return Icons.local_parking;
      case 'traffic light violation':
        return Icons.traffic;
      case 'no helmet':
        return Icons.sports_motorsports;
      case 'reckless driving':
        return Icons.warning;
      case 'no license':
        return Icons.badge;
      case 'expired registration':
        return Icons.assignment_late;
      default:
        return Icons.report_problem;
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _getOrdinalNumber(int number) {
    if (number <= 0) return '${number}th Offense';
    
    int lastDigit = number % 10;
    int lastTwoDigits = number % 100;
    
    // Handle special cases for 11th, 12th, 13th
    if (lastTwoDigits >= 11 && lastTwoDigits <= 13) {
      return '${number}th Offense';
    }
    
    // Handle regular cases
    // Examples: 1st, 2nd, 3rd, 4th, 5th, 21st, 22nd, 23rd, 101st, 102nd, 103rd
    switch (lastDigit) {
      case 1:
        return '${number}st Offense';
      case 2:
        return '${number}nd Offense';
      case 3:
        return '${number}rd Offense';
      default:
        return '${number}th Offense';
    }
  }

  Color _getOffenseColor(int repetition) {
    switch (repetition) {
      case 1:
        return Colors.green;    // 1st offense - Green
      case 2:
        return Colors.orange;   // 2nd offense - Warning/Orange
      default:
        return Colors.red;      // 3rd+ offenses - Red/Danger
    }
  }
}
