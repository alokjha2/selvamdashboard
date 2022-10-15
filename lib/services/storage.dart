import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as path;

class Storage {
  static final Storage _storageInstance = Storage._();
  FirebaseStorage storage = FirebaseStorage.instance;
  factory Storage() {
    return _storageInstance;
  }

  Storage._();

  Future<Reference?> uploadFile(PlatformFile mediaInfo, String ref, String fileName) async {
    try {
      String? mimeType = mime(path.basename(mediaInfo.name));

      final String? extension = extensionFromMime(mimeType!);

      var metadata = SettableMetadata(
        contentType: mimeType,
      );
      Reference storageReference = storage.ref(ref).child(fileName + ".$extension");
      var task = await storageReference.putData(mediaInfo.bytes!, metadata);
      return task.ref;
    } catch (e) {
      print("File Upload Error $e");
      return null;
    }
  }
}
