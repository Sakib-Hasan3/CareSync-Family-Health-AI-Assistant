/// Document type enum
enum DocumentType {
  prescription,
  labReport,
  insuranceCard,
  medicalRecord,
  xray,
  mri,
  ultrasound,
  vaccination,
  discharge,
  other,
}

/// Document model
class Document {
  final String id;
  final String userId;
  final String? familyMemberId;
  final String name;
  final DocumentType type;
  final String? description;
  final String filePath;
  final String? thumbnailPath;
  final int fileSize;
  final String mimeType;
  final DateTime dateCreated;
  final String? extractedText;
  final Map<String, dynamic>? ocrData;
  final List<String> tags;
  final bool isConfidential;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.userId,
    this.familyMemberId,
    required this.name,
    required this.type,
    this.description,
    required this.filePath,
    this.thumbnailPath,
    required this.fileSize,
    required this.mimeType,
    required this.dateCreated,
    this.extractedText,
    this.ocrData,
    this.tags = const [],
    this.isConfidential = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if document is an image
  bool get isImage {
    return mimeType.startsWith('image/');
  }

  /// Check if document is a PDF
  bool get isPdf {
    return mimeType == 'application/pdf';
  }

  /// Get file extension
  String get fileExtension {
    return filePath.split('.').last.toLowerCase();
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get type description
  String get typeDescription {
    switch (type) {
      case DocumentType.prescription:
        return 'Prescription';
      case DocumentType.labReport:
        return 'Lab Report';
      case DocumentType.insuranceCard:
        return 'Insurance Card';
      case DocumentType.medicalRecord:
        return 'Medical Record';
      case DocumentType.xray:
        return 'X-Ray';
      case DocumentType.mri:
        return 'MRI';
      case DocumentType.ultrasound:
        return 'Ultrasound';
      case DocumentType.vaccination:
        return 'Vaccination Record';
      case DocumentType.discharge:
        return 'Discharge Summary';
      case DocumentType.other:
        return 'Other';
    }
  }

  /// Create Document from JSON
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      userId: json['userId'] as String,
      familyMemberId: json['familyMemberId'] as String?,
      name: json['name'] as String,
      type: DocumentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => DocumentType.other,
      ),
      description: json['description'] as String?,
      filePath: json['filePath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      extractedText: json['extractedText'] as String?,
      ocrData: json['ocrData'] as Map<String, dynamic>?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isConfidential: json['isConfidential'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert Document to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'familyMemberId': familyMemberId,
      'name': name,
      'type': type.toString().split('.').last,
      'description': description,
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'dateCreated': dateCreated.toIso8601String(),
      'extractedText': extractedText,
      'ocrData': ocrData,
      'tags': tags,
      'isConfidential': isConfidential,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Document copyWith({
    String? id,
    String? userId,
    String? familyMemberId,
    String? name,
    DocumentType? type,
    String? description,
    String? filePath,
    String? thumbnailPath,
    int? fileSize,
    String? mimeType,
    DateTime? dateCreated,
    String? extractedText,
    Map<String, dynamic>? ocrData,
    List<String>? tags,
    bool? isConfidential,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      dateCreated: dateCreated ?? this.dateCreated,
      extractedText: extractedText ?? this.extractedText,
      ocrData: ocrData ?? this.ocrData,
      tags: tags ?? this.tags,
      isConfidential: isConfidential ?? this.isConfidential,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Document(id: $id, name: $name, type: $typeDescription)';
  }
}
