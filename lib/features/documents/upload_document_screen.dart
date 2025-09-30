import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/custom_button.dart';

/// Upload document screen
class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedType;
  String? _selectedSource;
  bool _isUploading = false;
  bool _hasSelectedFile = false;
  String? _fileName;

  final List<String> _documentTypes = [
    'Prescription',
    'Lab Report',
    'Insurance Card',
    'Medical Record',
    'X-Ray',
    'MRI',
    'Ultrasound',
    'Vaccination Record',
    'Discharge Summary',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.uploadDocument),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose how to add your document',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _takePicture,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _chooseFromGallery,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('From Gallery'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _chooseFile,
                        icon: const Icon(Icons.insert_drive_file),
                        label: const Text('Choose File'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_hasSelectedFile) ..[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description, color: Colors.blue),
                  title: Text(_fileName ?? 'Selected file'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _hasSelectedFile = false;
                        _fileName = null;
                      });
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Document Name',
                prefixIcon: Icon(Icons.title),
                hintText: 'e.g., Blood Test Results',
              ),
              validator: (value) => Validators.required(value, 'Document name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: AppStrings.documentType,
                prefixIcon: Icon(Icons.category),
              ),
              items: _documentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              validator: (value) => value == null ? 'Please select document type' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.description),
                hintText: 'Additional notes about this document',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your documents are encrypted and stored securely. Only you and authorized family members can access them.',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Upload Document',
              onPressed: _hasSelectedFile ? _uploadDocument : null,
              isLoading: _isUploading,
            ),
          ],
        ),
      ),
    );
  }

  void _takePicture() {
    // Simulate taking a picture
    setState(() {
      _hasSelectedFile = true;
      _fileName = 'Camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      _selectedSource = 'camera';
    });
    AppUtils.showSuccessSnackBar(context, 'Photo captured successfully!');
  }

  void _chooseFromGallery() {
    // Simulate choosing from gallery
    setState(() {
      _hasSelectedFile = true;
      _fileName = 'Gallery_image.jpg';
      _selectedSource = 'gallery';
    });
    AppUtils.showSuccessSnackBar(context, 'Image selected from gallery!');
  }

  void _chooseFile() {
    // Simulate file picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose File Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF Document'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _hasSelectedFile = true;
                  _fileName = 'Document.pdf';
                  _selectedSource = 'file';
                });
                AppUtils.showSuccessSnackBar(context, 'PDF file selected!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.green),
              title: const Text('Image File'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _hasSelectedFile = true;
                  _fileName = 'Document.png';
                  _selectedSource = 'file';
                });
                AppUtils.showSuccessSnackBar(context, 'Image file selected!');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _uploadDocument() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isUploading = true);
      
      try {
        // Simulate upload with progress
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          AppUtils.showSuccessSnackBar(
            context, 
            'Document uploaded successfully!'
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showErrorSnackBar(context, 'Failed to upload document');
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}