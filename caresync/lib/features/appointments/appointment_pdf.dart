import 'models/appointment.dart';

/// Simple text-based PDF placeholder generator.
/// If you want a real PDF, add the `pdf` and `printing` packages and replace
/// this with actual PDF bytes. For now we return UTF-8 bytes of a formatted
/// text which can be saved as .txt or used by a share/save flow.
class AppointmentPdf {
  static List<int> generatePlainText(Appointment a) {
    final b = StringBuffer();
    b.writeln('Appointment Confirmation');
    b.writeln('------------------------');
    b.writeln('Appointment ID: ${a.id}');
    b.writeln('Title: ${a.title}');
    b.writeln(
      'Doctor: ${a.doctor}${a.specialty != null ? ' (${a.specialty})' : ''}',
    );
    b.writeln('Center: ${a.centerName ?? a.location}');
    b.writeln('Date: ${a.datetime.toLocal()}');
    if ((a.patientName ?? '').isNotEmpty)
      b.writeln('Patient: ${a.patientName}');
    if ((a.patientPhone ?? '').isNotEmpty)
      b.writeln('Phone: ${a.patientPhone}');
    if ((a.patientEmail ?? '').isNotEmpty)
      b.writeln('Email: ${a.patientEmail}');
    if ((a.patientNationalId ?? '').isNotEmpty)
      b.writeln('NID/Patient ID: ${a.patientNationalId}');
    if ((a.notes ?? '').isNotEmpty) b.writeln('Notes: ${a.notes}');
    b.writeln(
      'Contact: ${(a.centerContactPhone ?? '')} ${(a.centerContactEmail ?? '')}'
          .trim(),
    );
    return b.toString().codeUnits;
  }
}
