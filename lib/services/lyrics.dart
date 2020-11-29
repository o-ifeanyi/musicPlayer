import 'package:dio/dio.dart';
import 'package:html/parser.dart' as parser;
import 'package:musicPlayer/models/exception.dart';
import 'package:musicPlayer/services/secrets.dart';

class Lyrics {
  static Future<List<String>> getLyrics(String artist, String title) async {
    Dio dio = Dio();
    if (title.startsWith(RegExp(r'\d{1,2}\. '))) {
      print('dot guy');
      title = title.split(RegExp(r'\d{1,2}\. ')).last;
      print(title);
    }
    if (artist.toLowerCase().contains('unknown artist')) {
      throw CustomException('Artist name is required, try editing song info');
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
      if (response.statusCode == 429) {
        print('${response.statusCode} ==> too much request');
        throw CustomException('Too many request, try again later');
      }
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
    } on CustomException catch (err) {
      throw err;
    } on DioError catch (err) {
      print(err);
      if (err.message.contains('Failed host lookup')) {
        throw CustomException('Please check your network and try again');
      }
      throw CustomException('Something went wrong, try again later');
    } catch (e) {
      print(e);
      throw CustomException('Something went wrong, try again later');
    }
    try {
      print('getting from azlyrics');
      print('songlink0 == $songLink0');
      var response = await dio.get(songLink0);
      var document = parser.parse(response.data);
      var divs = document.querySelectorAll('div');
      for (var div in divs) {
        if (div.className == '' &&
            div.innerHtml.contains(RegExp(r'<!--.+-->'))) {
          result = div.innerHtml
              .replaceAll('<br>', '')
              .replaceAll(RegExp(r'<!--.+-->'), '')
              .replaceAll('<i>[', '')
              .replaceAll(':]</i>', '')
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
        throw CustomException('Sorry, lyrics not found');
      }
      var response = await dio.get(songLink1);
      var document = parser.parse(response.data);
      var lyricsBody = document.querySelector('#view_lyrics');
      if (lyricsBody == null) {
        print(lyricsBody);
        throw CustomException('Sorry, lyrics not found');
      }
      result = lyricsBody.innerHtml
          .replaceAll('<br>', '')
          .replaceAll(RegExp(r'\[.+\]'), '')
          .replaceAll(RegExp(r'-?&amp;#\d{5};'), '')
          .trim();
      if (result == null) {
        throw CustomException('Sorry, lyrics not found');
      }
    }
    return List<String>.from(result.split('\n'));
  }
}
