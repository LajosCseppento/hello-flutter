import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'db.dart';
import 'firebase_options.dart';
import 'guestbook_message.dart';

enum Attending { yes, no, unknown }

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  int _attendees = 0;
  int get attendees => _attendees;

  Attending _attending = Attending.unknown;
  StreamSubscription<DocumentSnapshot>? _attendingSubscription;
  Attending get attending => _attending;
  set attending(Attending attending) {
    final userDoc = FirebaseFirestore.instance
        .collection(AttendeesCollection.collectionName)
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if (attending == Attending.yes) {
      userDoc.set(<String, dynamic>{AttendeesCollection.attending: true});
    } else {
      userDoc.set(<String, dynamic>{AttendeesCollection.attending: false});
    }
  }

  StreamSubscription<QuerySnapshot>? _guestbookSubscription;
  List<GuestbookMessage> _guestbookMessages = [];
  List<GuestbookMessage> get guestbookMessages => _guestbookMessages;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseFirestore.instance
        .collection(AttendeesCollection.collectionName)
        .where(AttendeesCollection.attending, isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _attendees = snapshot.docs.length;
      notifyListeners();
    });

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        _attendingSubscription = FirebaseFirestore.instance
            .collection(AttendeesCollection.collectionName)
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.data() != null) {
            if (snapshot.data()!['attending'] as bool) {
              _attending = Attending.yes;
            } else {
              _attending = Attending.no;
            }
          } else {
            _attending = Attending.unknown;
          }
          notifyListeners();
        });

        _guestbookSubscription = FirebaseFirestore.instance
            .collection(GuestbookCollection.collectionName)
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestbookMessages = [];
          for (final document in snapshot.docs) {
            _guestbookMessages.add(
              GuestbookMessage(
                name: document.data()[GuestbookCollection.name] as String,
                message: document.data()[GuestbookCollection.text] as String,
              ),
            );
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;

        _attendingSubscription?.cancel();

        _guestbookMessages = [];
        _guestbookSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  Future<DocumentReference> addMessageToGuestbook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection(GuestbookCollection.collectionName)
        .add(<String, dynamic>{
      GuestbookCollection.name: FirebaseAuth.instance.currentUser!.displayName,
      GuestbookCollection.text: message,
      GuestbookCollection.timestamp: DateTime.now().millisecondsSinceEpoch,
      GuestbookCollection.userId: FirebaseAuth.instance.currentUser!.uid,
    });
  }
}
