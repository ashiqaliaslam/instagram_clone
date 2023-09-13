# instantgram_clone

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```CEL
rules_version = '2';
service cloud.firestore {
    match /databases/{database}/documents {
        match /{collectionName}/{document=**} {
            allow read, update: if request.auth != null;
            allow create: if request.auth != null;
            allow delete: if request.auth != null && ((collectionName == "likes" || collectionName == "comments") || request.auth.uid == resource.data.uid);
        }
    }
}
```

## Storage Rules

```CEL
rules_version = '2';
service firebase.storage {
    match /b/{bucket}/o {
        match /{collectionId}/{allPaths=**} {
            allow create, update, write: if request.auth != null && request.auth.uid == collectionId;
            allow read: if request.auth != null;
        }
    }
}
```

`ios/Runner/info.plist`

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>$(PRODUCT_NAME) would like to access your photos</string>
```

## Providers used

```dart
// StateNotifierProvider<Notifier, NotifierObject>
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (_) => AuthStateNotifier(),
);
```

```dart
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.result == AuthResult.success;
});
```

```dart
final userIdProvider =
    Provider<UserId?>((ref) => ref.watch(authStateProvider).userId);
```

```dart
final deleteCommentProvider =
    StateNotifierProvider<DeleteCommentStateNotifier, IsLoading>(
  (ref) => DeleteCommentStateNotifier(),
);
```

```dart
final postCommentsProvider = StreamProvider.family
    .autoDispose<Iterable<Comment>, RequestForPostAndComments>((
  ref,
  RequestForPostAndComments request,
) {
  final controller = StreamController<Iterable<Comment>>();

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.comments)
      .where(
        FirebaseFieldName.postId,
        isEqualTo: request.postId,
      )
      .snapshots()
      .listen(
    (snapshot) {
      final documents = snapshot.docs;
      final limitedDocuments =
          request.limit != null ? documents.take(request.limit!) : documents;
      final comments = limitedDocuments
          .where(
            (doc) => !doc.metadata.hasPendingWrites,
          )
          .map(
            (document) => Comment(
              id: document.id,
              document.data(),
            ),
          );

      final result = comments.applySortingFrom(request);
      controller.sink.add(result);
    },
  );

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});
```

```dart
final sendCommentProvider =
    StateNotifierProvider<SendCommentNotifier, IsLoading>(
  (ref) => SendCommentNotifier(),
);
```

```dart
final imageUploaderProvider =
    StateNotifierProvider<ImageUploadNotifier, IsLoading>(
        (ref) => ImageUploadNotifier());
```

```dart
// FutureProvider.family.autoDispose<RETURNVALUE, INPUTVALUE>((ref) => null);
final thumbnailProvider = FutureProvider.family
    .autoDispose<ImageWithAspectRatio, ThumbnailRequest>(
        (ref, ThumbnailRequest request) async {
  final Image image;

  switch (request.fileType) {
    case FileType.image:
      image = Image.file(
        request.file,
        fit: BoxFit.fitHeight,
      );
    case FileType.video:
      final thumb = await VideoThumbnail.thumbnailData(
        video: request.file.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      if (thumb == null) {
        throw const CouldNotBuildThumbnailException();
      }
      image = Image.memory(
        thumb,
        fit: BoxFit.fitHeight,
      );
      break;
  }
  final aspectRatio = await image.getAspectRatio();
  return ImageWithAspectRatio(image: image, aspectRatio: aspectRatio);
});
```

```dart
final likeDislikePostProvider = Provider((ref) => null);
```

```dart
final hasLikedPostProvider = StreamProvider.family.autoDispose<bool, PostId>(
  (ref, PostId postId) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return Stream<bool>.value(false);
    }

    final controller = StreamController<bool>();

    final sub = FirebaseFirestore.instance
        .collection(FirebaseCollectionName.likes)
        .where(FirebaseFieldName.postId, isEqualTo: postId)
        .where(FirebaseFieldName.userId, isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        controller.add(true);
      } else {
        controller.add(false);
      }
    });

    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  },
);
```

```dart
final postLikesCountProvider = StreamProvider.family.autoDispose<int, PostId>(
  (
    ref,
    PostId postId,
  ) {
    final controller = StreamController<int>.broadcast();

    controller.onListen = () {
      controller.sink.add(0);
    };

    final sub = FirebaseFirestore.instance
        .collection(FirebaseCollectionName.likes)
        .where(FirebaseFieldName.postId, isEqualTo: postId)
        .snapshots()
        .listen((snapshot) {
      controller.sink.add(snapshot.docs.length);
    });

    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  },
);
```

```dart
final postSettingProvider =
    StateNotifierProvider<PostSettingNotifier, Map<PostSetting, bool>>(
        (ref) => PostSettingNotifier());
```

```dart
final allPostsProvider = StreamProvider.autoDispose<Iterable<Post>>(
  (ref) {
    final controller = StreamController<Iterable<Post>>();

    final sub = FirebaseFirestore.instance
        .collection(FirebaseCollectionName.posts)
        .orderBy(FirebaseFieldName.createdAt, descending: true)
        .snapshots()
        .listen(
      (snapshots) {
        final posts = snapshots.docs.map(
          (doc) => Post(json: doc.data(), postId: doc.id),
        );
        controller.sink.add(posts);
      },
    );

    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  },
);
```

```dart
final canCurrentUserDeletePostProvider =
    StreamProvider.autoDispose.family<bool, Post>((ref, Post post) async* {
  final userId = ref.watch(userIdProvider);
  yield userId == post.userId;
});
```

```dart
final deletePostProvider =
    StateNotifierProvider<DeletePostStateNotifier, IsLoading>(
  (ref) => DeletePostStateNotifier(),
);
```

```dart
final postsBySearchTermProvider =
    StreamProvider.family.autoDispose<Iterable<Post>, SearchTerm>(
  (ref, SearchTerm searchTerm) {
    final controller = StreamController<Iterable<Post>>();

    final sub = FirebaseFirestore.instance
        .collection(
          FirebaseCollectionName.posts,
        )
        .orderBy(
          FirebaseFieldName.createdAt,
          descending: true,
        )
        .snapshots()
        .listen(
      (snapshot) {
        final posts = snapshot.docs
            .map(
              (doc) => Post(
                json: doc.data(),
                postId: doc.id,
              ),
            )
            .where(
              (post) => post.message.toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  ),
            );
        controller.sink.add(posts);
      },
    );

    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  },
);
```

```dart
final specificPostWithCommentsProvider = StreamProvider.family
    .autoDispose<PostWithComments, RequestForPostAndComments>((
  ref,
  RequestForPostAndComments request,
) {
  final controller = StreamController<PostWithComments>();

  Post? post;
  Iterable<Comment>? comments;

  void notify() {
    final localPost = post;
    if (localPost == null) {
      return;
    }

    final outputComments = (comments ?? []).applySortingFrom(request);

    final result = PostWithComments(
      post: localPost,
      comments: outputComments,
    );
    controller.sink.add(result);
  }

  // watch changes to the post

  final postSub = FirebaseFirestore.instance
      .collection(
        FirebaseCollectionName.posts,
      )
      .where(
        FieldPath.documentId,
        isEqualTo: request.postId,
      )
      .limit(1)
      .snapshots()
      .listen(
    (snapshot) {
      if (snapshot.docs.isEmpty) {
        post = null;
        comments = null;
        notify();
        return;
      }
      final doc = snapshot.docs.first;
      if (doc.metadata.hasPendingWrites) {
        return;
      }
      post = Post(
        postId: doc.id,
        json: doc.data(),
      );
      notify();
    },
  );

  // watch changes to the comments

  final commentsQuery = FirebaseFirestore.instance
      .collection(
        FirebaseCollectionName.comments,
      )
      .where(
        FirebaseFieldName.postId,
        isEqualTo: request.postId,
      )
      .orderBy(
        FirebaseFieldName.createdAt,
        descending: true,
      );

  final limitedCommentsQuery = request.limit != null
      ? commentsQuery.limit(request.limit!)
      : commentsQuery;

  final commentsSub = limitedCommentsQuery.snapshots().listen(
    (snapshot) {
      comments = snapshot.docs
          .where(
            (doc) => !doc.metadata.hasPendingWrites,
          )
          .map(
            (doc) => Comment(
              doc.data(),
              id: doc.id,
            ),
          );
      notify();
    },
  );

  ref.onDispose(() {
    postSub.cancel();
    commentsSub.cancel();
    controller.close();
  });

  return controller.stream;
});
```

```dart
final userPostsProvider = StreamProvider.autoDispose<Iterable<Post>>((ref) {
  final userId = ref.watch(userIdProvider);
  final controller = StreamController<Iterable<Post>>();

  controller.onListen = () {
    controller.sink.add([]);
  };

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.posts)
      .orderBy(FirebaseFieldName.createdAt, descending: true)
      .where(PostKey.userId, isEqualTo: userId)
      .snapshots()
      .listen(
    (snapshot) {
      final documents = snapshot.docs;
      final posts =
          documents.where((doc) => !doc.metadata.hasPendingWrites).map(
                (doc) => Post(postId: doc.id, json: doc.data()),
              );
      controller.sink.add(posts);
    },
  );

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});
```

```dart
final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final isUploadingImage = ref.watch(imageUploaderProvider);

  return authState.isLoading || isUploadingImage;
// TODO: is_loading_provider.dart
});
```

```dart
final userInfoModelProvider =
    StreamProvider.family.autoDispose<UserInfoModel, UserId>(
  (ref, UserId userId) {
    final controller = StreamController<UserInfoModel>();

    final sub = FirebaseFirestore.instance
        .collection(FirebaseCollectionName.users)
        .where(FirebaseFieldName.userId, isEqualTo: userId)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final json = doc.data();
        final userInfoModel = UserInfoModel.fromJson(
          json,
          userId: userId,
        );
        controller.add(userInfoModel);
      }
    });

    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  },
);
```
