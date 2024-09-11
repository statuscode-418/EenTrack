import 'package:eentrack/models/attendee_model.dart';

import '../../models/meeting_model.dart';
import '../../models/user_model.dart';

abstract class DBModel {
  // User
  Future<void> init();
  Future<User> createUser(User user);
  Future<User?> getUser(String uid);
  Future<List<User>> getUsers(List<String> uids);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String uid);

  // Meetings
  Future<Meeting> createMeeting(String uid, Meeting meeting);
  Future<Meeting?> getMeeting(String uid, String mid);
  Stream<List<Meeting>> getMeetings(String uid);
  Stream<List<Meeting>> getCoHostedMeetings(String uid);
  Future<Meeting> updateMeeting(String uid, Meeting meeting);
  Future<void> deleteMeeting(String uid, String mid);

  // Meeting Attendees
  Future<void> addAttendee(String uid, String mid, Attendee attendee);
  Future<void> updateAttendee(String uid, String mid, Attendee attendee);
  Future<void> removeAttendee(String uid, String mid, Attendee attendee);
  Stream<List<Attendee>> getAttendees(String uid, String mid);
  Stream<List<Attendee>> getAddedAttendees(String uid, String mid);
  Stream<List<Attendee>> getLeftAttendees(String uid, String mid);
  Future<List<Attendee>> getAttendeesList(String uid, String mid);
  Future<bool> isAttendee(String uid, String mid, String aid);

  Future<void> saveAttendeeData(
      String meetingId,
      String uuid,
      String name,
      String dietaryPreference,
      String whatsappNumber,
      String university,
      String paperNumber);
}
