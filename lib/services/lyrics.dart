import 'package:dio/dio.dart';
import 'package:html/parser.dart' as parser;
import 'package:musicPlayer/services/secrets.dart';

class Lyrics {
  static Future<List<String>> getLyrics(String artist, String title) async {
    Dio dio = Dio();
    if (title.startsWith(RegExp(r'\d{1,2}\. '))) {
      print('dot guy');
      title = title.split(RegExp(r'\d{1,2}\. ')).last;
      print(title);
    }
    var result = '';
    var songLink0;
    var songLink1;
    final arguments = [...artist.split(RegExp(r'[\s-]')), ...title.split(' ')];
    final query =
        arguments.fold('', (prevValue, element) => prevValue + element + '+') +
            '$kTag0+$kTag1';
    final url = 'https://www.google.com/search?q=$query';

    try {
      print('\nGoogling ==> $url');
      var response = await dio.get(url);
      var document = parser.parse(response.data);
      final links = document.querySelectorAll('a');
      print(links.length);
      for (var link in links) {
        if (link.attributes['href'].contains('$kLyricsLink0/lyrics')) {
          songLink0 = link.attributes['href'].split('q=').last.split('&').first;
        }
        if (link.attributes['href'].contains('$kLyricsLink1/lyrics')) {
          songLink1 = link.attributes['href'].split('q=').last.split('&').first;
        }
      }
    } catch (e) {
      print(e);
      return [];
    }
    try {
      print('getting from azlyrics');
      print('songlink0 == $songLink0');
      var response = await dio.get(songLink0);
      var document = parser.parse(response.data);
      var divs = document.querySelectorAll('div');
      for (var div in divs) {
        if (div.className == '' && div.innerHtml.contains(RegExp(r'<!--.+-->'))) {
          result = div.innerHtml
              .replaceAll('<br>', '')
              .replaceAll(RegExp(r'<!--.+-->'), '')
              .trim();
          break;
        }
      }
      if (result == '') {
        // trigger the catch block
        throw Error();
      }
    } catch (e) {
      print('getting from absolute lyrics');
      print('songlink1 == $songLink1');
      if (songLink1 == null) {
        return [];
      }
      var response = await dio.get(songLink1);
      var document = parser.parse(response.data);
      var lyricsBody = document.querySelector('#view_lyrics');
      if (lyricsBody == null) {
        print(lyricsBody);
        return [];
      }
      result = lyricsBody.innerHtml
          .replaceAll('<br>', '')
          .replaceAll(RegExp(r'\[.+\]'), '')
          .replaceAll(RegExp(r'-?&amp;#\d{5};'), '')
          .trim();
    }
    return List<String>.from(result.split('\n'));
  }
}
