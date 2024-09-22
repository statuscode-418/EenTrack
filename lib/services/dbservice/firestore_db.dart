import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eentrack/models/attendee_model.dart';
import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/model_consts.dart' as model_consts;
import 'package:eentrack/models/participant_model.dart';

import '../../models/meeting_model.dart';
import '../../models/user_model.dart';
import 'db_exception.dart';
import 'db_model.dart';
import 'db_consts.dart' as db_consts;

class FirestoreDB implements DBModel {
  late final FirebaseFirestore _db;

  @override
  Future<void> init() async {
    _db = FirebaseFirestore.instance;
  }

  @override
  Future<User> createUser(User user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }

    return user;
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Future<User?> getUser(String uid) async {
    try {
      var snapshot = await _db.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return User.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Future<List<User>> getUsers(List<String> uids) async {
    try {
      var futures = uids.map((e) => getUser(e));
      var users = await Future.wait(futures);
      return users.whereType<User>().toList();
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<User> updateUser(User user) async {
    try {
      await _db.collection('users').doc(user.uid).update(user.toMap());
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
    return user;
  }

  // Meetings
  @override
  Future<Meeting> createMeeting(String uid, Meeting meeting) async {
    try {
      Meeting newMeeting = Meeting(
        id: meeting.id,
        hostid: meeting.hostid,
        isHost: meeting.isHost,
        coHosts: meeting.coHosts,
        title: meeting.title,
        description: meeting.description,
        date: meeting.date,
      );

      await _db
          .collection(db_consts.meetings)
          .doc(newMeeting.id)
          .set(newMeeting.toMap());
      return newMeeting;
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Future<Meeting> updateMeeting(String uid, Meeting meeting) async {
    try {
      await _db
          .collection(db_consts.meetings)
          .doc(meeting.id)
          .update(meeting.toMap());
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
    return meeting;
  }

  @override
  Future<Meeting?> getMeeting(String uid, String mid) async {
    try {
      var snapshot = await _db.collection(db_consts.meetings).doc(mid).get();
      if (snapshot.exists) {
        return Meeting.fromMap(snapshot.data()!, uid);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Stream<List<Meeting>> getMeetingsStream(String uid) {
    try {
      return _db
          .collection(db_consts.meetings)
          .orderBy(model_consts.date, descending: true)
          .where(model_consts.hostid, isEqualTo: uid)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Meeting.fromMap(doc.data(), uid))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Future<List<Meeting>> getMeetings(String uid) async {
    try {
      var meetingsSnap = await _db
          .collection(db_consts.meetings)
          .orderBy(model_consts.date, descending: true)
          .where(model_consts.hostid, isEqualTo: uid)
          .get();

      return meetingsSnap.docs
          .map((doc) => Meeting.fromMap(doc.data(), uid))
          .toList();
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Stream<List<Meeting>> getCoHostedMeetingsStream(String uid) {
    try {
      return _db
          .collection(db_consts.meetings)
          .where(model_consts.coHosts, arrayContains: uid)
          .orderBy(model_consts.date, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Meeting.fromMap(doc.data(), uid))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<Meeting>> getCoHostedMeetings(String uid) async {
    try {
      var snap = await _db
          .collection(db_consts.meetings)
          .where(model_consts.coHosts, arrayContains: uid)
          .orderBy(model_consts.date, descending: true)
          .get();
      return snap.docs.map((doc) => Meeting.fromMap(doc.data(), uid)).toList();
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> deleteMeeting(String uid, String mid) async {
    try {
      var attendees = await getAttendeesList(uid, mid);
      var futures = attendees.map((e) => removeAttendee(uid, mid, e));
      await Future.wait(futures);
      await _db.collection(db_consts.meetings).doc(mid).delete();
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Future<void> addAttendee(String uid, String mid, Attendee attendee) async {
    try {
      await _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.attendee)
          .doc(attendee.uid)
          .set(attendee.toMap());
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Future<void> updateAttendee(String uid, String mid, Attendee attendee) async {
    try {
      var atd = await _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.attendee)
          .doc(attendee.uid)
          .get();

      if (!atd.exists) {
        throw DBException('Attendee does not exist');
      }
      await atd.reference.update(attendee.toMap());
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Stream<List<Attendee>> getAttendees(String uid, String mid) {
    try {
      return _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.attendee)
          .orderBy(model_consts.date, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Attendee.fromMap(doc.data()))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Stream<List<Attendee>> getAddedAttendees(String uid, String mid) {
    try {
      return _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.attendee)
          .where(model_consts.addedOn, isNull: false)
          .orderBy(model_consts.addedOn, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Attendee.fromMap(doc.data()))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Stream<List<Attendee>> getLeftAttendees(String uid, String mid) {
    try {
      return _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.attendee)
          .where(model_consts.leftOn, isNull: false)
          .orderBy(model_consts.leftOn, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Attendee.fromMap(doc.data()))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> removeAttendee(String uid, String mid, Attendee attendee) async {
    try {
      await _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.attendee)
          .doc(attendee.uid)
          .delete();
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Future<List<Attendee>> getAttendeesList(String uid, String mid) async {
    try {
      var snapshot = await _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.attendee)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => Attendee.fromMap(doc.data()))
            .toList();
      } else {
        return [];
      }
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Future<bool> isAttendee(String uid, String mid, String aid) async {
    try {
      final doc = await _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.attendee)
          .doc(aid)
          .get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    } on Exception catch (e) {
      throw DBException(e.toString());
    }
  }

  @override
  Future<void> addParticipant(ParticipantModel participant) async {
    try {
      await _db
          .collection(db_consts.meetings)
          .doc(participant.eventId)
          .collection(db_consts.participant)
          .doc(participant.userId)
          .set(participant.toMap());
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Stream<List<ParticipantModel>> getParticipantsStream(String mid) {
    try {
      return _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.participant)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ParticipantModel.fromMap(doc.data()))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<ParticipantModel>> getParticipants(String mid) async {
    try {
      var snapshot = await _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.participant)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => ParticipantModel.fromMap(doc.data()))
            .toList();
      } else {
        return [];
      }
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> removeParticipant(ParticipantModel participant) {
    try {
      return _db
          .collection(db_consts.meetings)
          .doc(participant.eventId)
          .collection(db_consts.participant)
          .doc(participant.userId)
          .delete();
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> updateParticipant(ParticipantModel participant) {
    try {
      return _db
          .collection(db_consts.meetings)
          .doc(participant.eventId)
          .collection(db_consts.participant)
          .doc(participant.userId)
          .update(participant.toMap());
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> markCheckPoint(
      String mid, String uid, String checkPointId) async {
    try {
      await _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.participant)
          .doc(uid)
          .update({checkPointId: true});
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> unmarkCheckPoint(
      String mid, String uid, String checkPointId) async {
    try {
      await _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.participant)
          .doc(uid)
          .update({checkPointId: FieldValue.delete()});
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> createCheckPoint(CheckpointModel checkPoint) async {
    try {
      await _db
          .collection(db_consts.meetings)
          .doc(checkPoint.mid)
          .collection(db_consts.checkPoint)
          .doc(checkPoint.id)
          .set(checkPoint.toMap());
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> deleteCheckPoint(CheckpointModel checkPoint) async {
    try {
      await _db
          .collection(db_consts.meetings)
          .doc(checkPoint.mid)
          .collection(db_consts.checkPoint)
          .doc(checkPoint.id)
          .delete();
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Stream<List<CheckpointModel>> getCheckPointsStream(String mid) {
    try {
      return _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.checkPoint)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => CheckpointModel.fromMap(doc.data()))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<CheckpointModel>> getCheckPoints(String mid) async {
    try {
      var snapshot = await _db
          .collection(db_consts.meetings)
          .doc(mid)
          .collection(db_consts.checkPoint)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => CheckpointModel.fromMap(doc.data()))
            .toList();
      } else {
        return [];
      }
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> updateCheckPoint(CheckpointModel checkPoint) async {
    try {
      await _db
          .collection(db_consts.meetings)
          .doc(checkPoint.mid)
          .collection(db_consts.checkPoint)
          .doc(checkPoint.id)
          .update(checkPoint.toMap());
    } on FirebaseException catch (e) {
      throw DBException(e.message ?? 'Unknown error');
    }
  }
}
