import 'package:eentrack/models/attendee_model.dart';
import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/participant_model.dart';

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
  Stream<List<Meeting>> getMeetingsStream(String uid);
  Stream<List<Meeting>> getCoHostedMeetingsStream(String uid);
  Future<List<Meeting>> getMeetings(String uid);
  Future<List<Meeting>> getCoHostedMeetings(String uid);
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

  // Participants
  Future<void> addParticipant(ParticipantModel participant);
  Future<void> updateParticipant(ParticipantModel participant);
  Future<void> removeParticipant(ParticipantModel participant);
  Stream<List<ParticipantModel>> getParticipantsStream(String mid);
  Future<List<ParticipantModel>> getParticipants(String mid);
  Future<void> markCheckPoint(String mid, String uid, String checkPointId);
  Future<void> unmarkCheckPoint(String mid, String uid, String checkPointId);

  Future<void> createCheckPoint(CheckpointModel checkPoint);
  Future<void> updateCheckPoint(CheckpointModel checkPoint);
  Future<void> deleteCheckPoint(CheckpointModel checkPoint);
  Stream<List<CheckpointModel>> getCheckPointsStream(String mid);

  Future<List<CheckpointModel>> getCheckPoints(String mid);
}
