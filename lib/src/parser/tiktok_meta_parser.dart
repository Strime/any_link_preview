import 'package:html/dom.dart';
import 'dart:convert';

import 'base.dart';
import 'util.dart';

/// Parses [Metadata] specifically from TikTok pages
class TikTokMetaParser with BaseMetaInfo {
  /// The [Document] to parse.
  final Document? _document;

  /// The extracted JSON data from TikTok's embedded script
  Map<String, dynamic>? _tikTokData;

  TikTokMetaParser(this._document) {
    _extractTikTokData();
  }

  /// Extracts the TikTok data from the embedded script
  void _extractTikTokData() {
    try {
      // Find the script containing TikTok's data
      final scriptElement = _document?.querySelector('script#__UNIVERSAL_DATA_FOR_REHYDRATION__');
      if (scriptElement != null) {
        final jsonText = scriptElement.text;
        final data = json.decode(jsonText) as Map<String, dynamic>;

        // Navigate to the video details section
        if (data.containsKey('__DEFAULT_SCOPE__') &&
            data['__DEFAULT_SCOPE__'].containsKey('webapp.video-detail')) {
          final videoDetail = data['__DEFAULT_SCOPE__']['webapp.video-detail'];
          _tikTokData = videoDetail;
        }
      }
    } catch (e) {
      print('Error extracting TikTok data: $e');
    }
  }

  /// Get the video description
  @override
  String? get title {
    try {
      return _tikTokData?['itemInfo']?['itemStruct']?['author']?['nickname'];
    } catch (e) {
      // Fallback to traditional method
      return _document?.head?.querySelector('title')?.text;
    }
  }

  /// Get the video description as meta description
  @override
  String? get desc {
    try {
      return _tikTokData?['itemInfo']?['itemStruct']?['desc'];
    } catch (e) {
      // Fallback to traditional method
      return _document?.head
          ?.querySelector("meta[name='description']")
          ?.attributes
          .get('content');
    }
  }

  /// Get the video cover image
  @override
  String? get image {
    try {
      return _tikTokData?['itemInfo']?['itemStruct']?['video']?['cover'];
    } catch (e) {
      // Fallback to traditional method
      return _document?.head
          ?.querySelector("meta[property='og:image']")
          ?.attributes
          .get('content');
    }
  }

  /// Get the author's name as site name
  @override
  String? get siteName {
    try {
      return _tikTokData?['itemInfo']?['itemStruct']?['author']?['nickname'];
    } catch (e) {
      // Fallback to traditional method
      return _document?.head
          ?.querySelector("meta[property='og:site_name']")
          ?.attributes
          .get('content');
    }
  }

  /// Get video URL
  String? get videoUrl {
    try {
      return _tikTokData?['itemInfo']?['itemStruct']?['video']?['playAddr'];
    } catch (e) {
      return null;
    }
  }

  /// Get video statistics
  Map<String, dynamic>? get stats {
    try {
      return _tikTokData?['itemInfo']?['itemStruct']?['stats'];
    } catch (e) {
      return null;
    }
  }

  /// Get hashtags
  List<String>? get hashtags {
    try {
      final textExtra = _tikTokData?['itemInfo']?['itemStruct']?['textExtra'] as List?;
      if (textExtra != null) {
        return textExtra
            .where((item) => item['hashtagName'] != null)
            .map<String>((item) => '#${item['hashtagName']}')
            .toList();
      }
    } catch (e) {
      print('Error extracting hashtags: $e');
    }
    return null;
  }

  @override
  String toString() => parse().toString();
}