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
      // return {};
    }
    var result = '';
    final arguments = [...artist.split(RegExp(r'[\s-]')), ...title.split(' ')];
    final query =
        arguments.fold('', (prevValue, element) => prevValue + element + '+') +
            kLyricsLink;
    final url = 'https://www.google.com/search?q=$query';

    var response = await dio.get(url);
    print('\nGoogling ==> $url');
    var document = parser.parse(response.data);
    final links = document.querySelectorAll('a');
    print(links.length);
    for (var link in links) {
      if (link.attributes['href'].contains(kLyricsLink)) {
        print(link.attributes['href']);
        var songLink =
            link.attributes['href'].split('q=').last.split('&').first;
        print('\nFound link ==> $songLink');
        response = await dio.get(songLink);
        document = parser.parse(response.data);
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
        break;
      }
    }
    return List<String>.from(result.split('\n'));
  }
}
