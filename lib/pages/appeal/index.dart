import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/app_theme/colors.dart';
import '../../shared/app_theme/fonts.dart';
import '../../shared/decorations/app_bg.dart';
import '../../shared/components/textfield/app_input_border.dart';
import 'handlers.dart';
import 'models/appeal_model.dart';

class AppealPage extends StatefulWidget {
  final String? prefilledTrackingNumber;
  
  const AppealPage({super.key, this.prefilledTrackingNumber});

  @override
  State<AppealPage> createState() => _AppealPageState();
}

class _AppealPageState extends State<AppealPage> {
  final _formKey = GlobalKey<FormState>();
  final _trackingNumberController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isSubmitting = false;
  bool _showUploadValidationError = false;
  final AppealHandlers _appealHandlers = AppealHandlers();
  final ImagePicker _picker = ImagePicker();

  // File lists
  List<File> _uploadedDocuments = [];
  List<File> _supportingDocuments = [];

  final int _maxFiles = 3;
  final double _maxFileSizeMB = 5.0;

  @override
  void initState() {
    super.initState();
    // Pre-fill tracking number if provided
    if (widget.prefilledTrackingNumber != null) {
      _trackingNumberController.text = widget.prefilledTrackingNumber!;
    }
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor().primary,
        foregroundColor: Colors.white,
        title: Text(
          'File an Appeal',
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
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.gavel,
                          color: Colors.blue,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Appeal a Violation',
                          style: TextStyle(
                            fontSize: FontSizes().h4,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'If you believe a violation was issued in error, you can file an appeal. Please provide all necessary details and supporting information.',
                      style: TextStyle(
                        fontSize: FontSizes().body,
                        color: MainColor().textPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Violation Tracking Number
              Text(
                'Violation Tracking Number *',
                style: TextStyle(
                  fontSize: FontSizes().body,
                  fontWeight: FontWeight.w600,
                  color: MainColor().textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _trackingNumberController,
                style: TextStyle(color: MainColor().textPrimary),
                decoration: appInputDecoration('Tracking Number').copyWith(
                  hintText: 'Enter violation tracking number',
                  prefixIcon: Icon(Icons.track_changes, color: MainColor().textPrimary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the violation tracking number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Reason for Appeal
              Text(
                'Reason for Appeal *',
                style: TextStyle(
                  fontSize: FontSizes().body,
                  fontWeight: FontWeight.w600,
                  color: MainColor().textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Characters: ${_reasonController.text.length}/1000',
                style: TextStyle(
                  fontSize: FontSizes().caption,
                  color: MainColor().textPrimary.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 4),
              TextFormField(
                controller: _reasonController,
                maxLines: 6,
                maxLength: 1000,
                style: TextStyle(color: MainColor().textPrimary),
                decoration: appInputDecoration('Reason for Appeal').copyWith(
                  hintText: 'Provide detailed explanation of why you are appealing this violation...',
                  alignLabelWithHint: true,
                  counterText: '', // Hide default counter
                ),
                onChanged: (value) {
                  setState(() {}); // Update character count
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a reason for your appeal';
                  }
                  if (value.length < 20) {
                    return 'Reason must be at least 20 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Upload Documents
              _buildFileUploadSection(
                'Upload Documents',
                'Upload pictures, videos, or documents that support your appeal',
                _uploadedDocuments,
                (files) => setState(() {
                  _uploadedDocuments = files;
                  if (files.isNotEmpty) {
                    _showUploadValidationError = false;
                  }
                }),
                false,
                showValidationError: _showUploadValidationError,
              ),
              SizedBox(height: 20),

              // Supporting Documents
              _buildFileUploadSection(
                'Supporting Documents',
                'Upload additional documents like affidavit, ID, etc. (optional)',
                _supportingDocuments,
                (files) => setState(() => _supportingDocuments = files),
                true,
              ),
              SizedBox(height: 30),

              // Guidelines Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Appeal Guidelines',
                          style: TextStyle(
                            fontSize: FontSizes().body,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Provide clear and factual information\n'
                      '• Supporting documents are recommended\n'
                      '• Each file must be under 5MB\n'
                      '• Maximum of 3 files per section',
                      style: TextStyle(
                        fontSize: FontSizes().caption,
                        color: MainColor().textPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAppeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MainColor().accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Submitting...'),
                          ],
                        )
                      : Text(
                          'Submit Appeal',
                          style: TextStyle(
                            fontSize: FontSizes().body,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection(
    String title,
    String description,
    List<File> files,
    Function(List<File>) onFilesChanged,
    bool isOptional, {
    bool showValidationError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title + (isOptional ? ' (Optional)' : ' *'),
          style: TextStyle(
            fontSize: FontSizes().body,
            fontWeight: FontWeight.w600,
            color: MainColor().textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: FontSizes().caption,
            color: MainColor().textPrimary.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 12),
        
        // File upload area
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: showValidationError && !isOptional && files.isEmpty
                  ? Colors.red
                  : Colors.white.withOpacity(0.3),
              width: showValidationError && !isOptional && files.isEmpty ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              if (files.length < _maxFiles)
                InkWell(
                  onTap: () => _showFilePickerDialog(files, onFilesChanged),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: MainColor().primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: MainColor().primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          color: MainColor().primary,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload files',
                          style: TextStyle(
                            color: MainColor().primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pictures, videos, or documents (Max 5MB each)',
                          style: TextStyle(
                            color: MainColor().textPrimary.withOpacity(0.6),
                            fontSize: FontSizes().caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Display uploaded files
              if (files.isNotEmpty) ...[
                SizedBox(height: 12),
                ...files.asMap().entries.map((entry) {
                  int index = entry.key;
                  File file = entry.value;
                  String fileName = file.path.split('/').last;
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(fileName),
                          color: Colors.green,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: TextStyle(
                                  color: MainColor().textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              FutureBuilder<int>(
                                future: file.length(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    double sizeInMB = snapshot.data! / (1024 * 1024);
                                    return Text(
                                      '${sizeInMB.toStringAsFixed(2)} MB',
                                      style: TextStyle(
                                        color: MainColor().textPrimary.withOpacity(0.6),
                                        fontSize: FontSizes().caption,
                                      ),
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            List<File> updatedFiles = List.from(files);
                            updatedFiles.removeAt(index);
                            onFilesChanged(updatedFiles);
                          },
                          icon: Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              
              if (files.length >= _maxFiles)
                Container(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Maximum of $_maxFiles files reached',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: FontSizes().caption,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Validation error message
        if (showValidationError && !isOptional && files.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Please upload at least one document',
              style: TextStyle(
                color: Colors.red,
                fontSize: FontSizes().caption,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showFilePickerDialog(List<File> currentFiles, Function(List<File>) onFilesChanged) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickFile('camera', currentFiles, onFilesChanged);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFile('gallery', currentFiles, onFilesChanged);
              },
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('Choose Document'),
              onTap: () {
                Navigator.pop(context);
                _pickFile('document', currentFiles, onFilesChanged);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(String type, List<File> currentFiles, Function(List<File>) onFilesChanged) async {
    try {
      File? file;
      
      if (type == 'camera') {
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) file = File(pickedFile.path);
      } else if (type == 'gallery') {
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) file = File(pickedFile.path);
      } else {
        // For documents, we'll use a simple approach for now
        // TODO: Implement proper file picker when package is available
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) file = File(pickedFile.path);
      }
      
      if (file != null) {
        // Check file size
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        
        if (fileSizeInMB > _maxFileSizeMB) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File size exceeds ${_maxFileSizeMB}MB limit'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        List<File> updatedFiles = List.from(currentFiles);
        updatedFiles.add(file);
        onFilesChanged(updatedFiles);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitAppeal() async {
    if (_formKey.currentState!.validate()) {
      // Check if required uploaded documents are provided
      if (_uploadedDocuments.isEmpty) {
        setState(() {
          _showUploadValidationError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload at least one supporting document'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Verify violation exists first
        bool violationExists = await _appealHandlers.verifyViolationExists(_trackingNumberController.text);
        if (!violationExists) {
          throw Exception('Violation with tracking number "${_trackingNumberController.text}" not found');
        }

        // Check if violation is eligible for appeal
        await _appealHandlers.validateViolationEligibility(_trackingNumberController.text);

        // Upload files
        List<String> uploadedDocumentUrls = [];
        List<String> supportingDocumentUrls = [];
        
        if (_uploadedDocuments.isNotEmpty) {
          uploadedDocumentUrls = await _appealHandlers.uploadFiles(_uploadedDocuments);
        }
        
        if (_supportingDocuments.isNotEmpty) {
          supportingDocumentUrls = await _appealHandlers.uploadFiles(_supportingDocuments);
        }

        // Create appeal model
        final appeal = AppealModel(
          violationTrackingNumber: _trackingNumberController.text,
          reasonForAppeal: _reasonController.text,
          uploadedDocuments: uploadedDocumentUrls,
          supportingDocuments: supportingDocumentUrls,
          createdAt: DateTime.now(),
          createdById: '', // Will be set in handlers
        );

        // Save appeal
        String? appealId = await _appealHandlers.saveAppeal(appeal);
        
        if (appealId != null && mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Appeal Submitted'),
                  ],
                ),
                content: Text(
                  'Your appeal has been successfully submitted. You will receive updates on the status of your appeal.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous page
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        if (mounted) {
          // Show error dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Error'),
                  ],
                ),
                content: Text(
                  e.toString().replaceAll('Exception: ', ''),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}
