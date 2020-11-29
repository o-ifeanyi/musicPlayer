import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:musicPlayer/models/song.dart';
import 'package:musicPlayer/providers/playList_database.dart';

class MockDatabase extends Mock implements PlayListDB {}

void main() {
  MockDatabase mockDatabase;
  String path;
  Song song;

  setUpAll(() {
    mockDatabase = MockDatabase();
    path = '/data/user/0/com.onuifeanyi.vybeplayer/app_flutter/playlist.db';
    song = Song(
      path: '',
      title: 'title',
      artist: 'artist',
      genre: '',
      album: '',
      year: '',
    );
  });

  tearDownAll(() {
    mockDatabase = null;
    song = null;
  });

  test('Create playlist', () async {

    when(mockDatabase.getPlaylistPath()).thenAnswer((_) => Future.value(path));

    await mockDatabase.createPlaylist('Favourites');

    print(mockDatabase.playList);
  });

  test('number of songs in playlist should increase by one', () async {

    when(mockDatabase.getPlaylistPath()).thenAnswer((_) => Future.value(path));

    int oldLenght = await mockDatabase.getLenght('Favourites');

    print(oldLenght);

    await mockDatabase.addToPlaylist('Favourites', song);

    int newLenght = await mockDatabase.getLenght('Favourites');

    expect(newLenght, (oldLenght + 1));
  });
}
