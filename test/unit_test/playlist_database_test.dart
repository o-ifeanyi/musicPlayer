import 'package:flutter_test/flutter_test.dart';
import 'package:musicPlayer/models/song.dart';
import 'package:musicPlayer/providers/playList_database.dart';

void main() {
  Song song = Song(
    path: '',
    title: 'title',
    artist: 'artist',
    genre: '',
    album: '',
    year: '',
  );
  test('number of songs in playlist should increase by one', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final playlistDB = PlayListDB();

    int oldLenght = await playlistDB.getLenght('Favourites');

    await playlistDB.addToPlaylist('Favourites', song);

    int newLenght = await playlistDB.getLenght('Favourites');

    expect(newLenght, (oldLenght + 1));
  });
}
