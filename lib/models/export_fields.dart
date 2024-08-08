enum ExportField {
  uid,
  name,
  department,
  roll,
  semester,
  email,
  github,
  linkedin,
  addedOn,
  leftOn,
  attendedFullMeeting,
  latitude,
  longitude,
  areLocationsSame,
}

extension ExportFieldExtension on ExportField {
  String get name {
    switch (this) {
      case ExportField.uid:
        return 'UID';
      case ExportField.name:
        return 'Name';
      case ExportField.department:
        return 'Department';
      case ExportField.roll:
        return 'Roll No';
      case ExportField.semester:
        return 'Semester';
      case ExportField.email:
        return 'Email';
      case ExportField.github:
        return 'Github';
      case ExportField.linkedin:
        return 'Linkedin';
      case ExportField.addedOn:
        return 'Added On';
      case ExportField.leftOn:
        return 'Left On';
      case ExportField.attendedFullMeeting:
        return 'Attended Full Meeting';
      case ExportField.latitude:
        return 'Latitude';
      case ExportField.longitude:
        return 'Longitude';
      case ExportField.areLocationsSame:
        return 'Are Locations Same';
      default:
        return '';
    }
  }
}
