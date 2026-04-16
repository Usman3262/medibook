import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/network/api_client.dart';
import '../core/network/cloudflare_r2_client.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Firebase
  await Firebase.initializeApp();

  // Firebase Services
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Network Clients
  getIt.registerSingleton<ApiClient>(ApiClient());

  // Cloudflare R2 Client
  getIt.registerSingleton<CloudflareR2Client>(
    CloudflareR2Client(
      accountId: 'YOUR_ACCOUNT_ID',
      accessKeyId: 'YOUR_ACCESS_KEY_ID',
      secretAccessKey: 'YOUR_SECRET_ACCESS_KEY',
      bucketName: 'YOUR_BUCKET_NAME',
    ),
  );

  // TODO: Register repositories
  // TODO: Register use cases
  // TODO: Register controllers
}
