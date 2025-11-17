import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppwriteService {
  static final Client client = Client();
  static late final Account account;
  static late final Databases databases;
  static late final Storage storage;

  // TODO: replace these placeholders
  static const String endpoint = '<<<APPWRITE_ENDPOINT>>>'; // e.g. https://cloud.appwrite.io/v1
  static const String projectId = '<<<PROJECT_ID>>>';
  static const String databaseId = '<<<DATABASE_ID>>>';
  static const String itemsCollectionId = '<<<ITEMS_COLLECTION_ID>>>';
  static const String imagesBucketId = 'images';
  static const String modelServerBase = '<<<MODEL_SERVER_URL>>>'; // e.g. https://lf-model.onrender.com

  static final _secure = FlutterSecureStorage();

  static String currentUserId = '<<NOT_SET>>';
  static String currentCollegeId = '<<NOT_SET>>';

  static Future<void> init() async {
    client.setEndpoint(endpoint).setProject(projectId);
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    try {
      final res = await account.get();
      currentUserId = res.$id;
      // get user metadata such as college from your users collection or account prefs
    } catch (e) {
      // not logged in
    }
  }

  // Sign up: this example creates a user (email) with temp password and a profile doc
  static Future<void> signUp({required String name, required String email, required String phone, required String college}) async {
    // NOTE: Appwrite currently requires email/password sign-up flow (or magic link).
    // For simplicity create a user with random password and create profile doc.
    final password = "TempPass!${DateTime.now().millisecondsSinceEpoch}";
    final res = await account.create(userId: ID.unique(), email: email, password: password, name: name);
    currentUserId = res.$id;
    // create profile in DB
    final profile = {
      "name": name,
      "email": email,
      "phone": phone,
      "collegeId": college,
      "userId": res.$id
    };
    await databases.createDocument(databaseId: databaseId, collectionId: 'users', documentId: ID.unique(), data: profile);
    currentCollegeId = college;
  }

  // Storage: upload image (local path)
  static Future<String> uploadImage(String filePath) async {
    final file = await storage.createFile(bucketId: imagesBucketId, fileId: ID.unique(), file: InputFile.fromPath(filePath));
    return file.$id;
  }

  // Create item doc
  static Future<void> createItem(Map<String, dynamic> item) async {
    await databases.createDocument(databaseId: databaseId, collectionId: itemsCollectionId, documentId: ID.unique(), data: item);
  }

  // Fetch caption from model server
  static Future<String?> fetchCaptionFromModelServer(File imageFile) async {
    final uri = Uri.parse('$modelServerBase/caption');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final streamed = await request.send();
    final txt = await streamed.stream.bytesToString();
    if (streamed.statusCode == 200) {
      final j = jsonDecode(txt);
      return j['caption'];
    }
    return null;
  }

  static Future<List<double>?> getImageEmbedding(File imageFile) async {
    final uri = Uri.parse('$modelServerBase/embed/image');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final streamed = await request.send();
    final txt = await streamed.stream.bytesToString();
    if (streamed.statusCode == 200) {
      final j = jsonDecode(txt);
      return (j['embedding'] as List).map((e) => (e as num).toDouble()).toList();
    }
    return null;
  }

  static Future<List<double>?> getTextEmbedding(String text) async {
    final uri = Uri.parse('$modelServerBase/embed/text');
    final r = await http.post(uri, body: jsonEncode({'text': text}), headers: {'Content-Type': 'application/json'});
    if (r.statusCode == 200) {
      final j = jsonDecode(r.body);
      return (j['embedding'] as List).map((e) => (e as num).toDouble()).toList();
    }
    return null;
  }

  // trigger server-side matching; implement server-side logic (Appwrite Function or model-server endpoint)
  static Future<void> triggerMatchJob() async {
    final uri = Uri.parse('$modelServerBase/trigger-match');
    try {
      await http.post(uri, headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print('triggerMatchJob error: $e');
    }
  }

  // List public items (a simple example: fetch docs via Appwrite REST requires JWT/service key; here assume you have an API endpoint publicItems)
  static Future<List> listPublicItems() async {
    // Quick approach: call an appwrite function or a custom endpoint that returns public items (avoid embedding secret keys in app)
    final uri = Uri.parse('$modelServerBase/public-items'); // implement on server
    final r = await http.get(uri);
    if (r.statusCode == 200) return jsonDecode(r.body);
    return [];
  }

  static Future<List> listMyItems() async {
    final uri = Uri.parse('$modelServerBase/my-items?userId=$currentUserId');
    final r = await http.get(uri);
    if (r.statusCode == 200) return jsonDecode(r.body);
    return [];
  }
}
