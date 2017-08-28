import 'dart:async';
import 'dart:io';

import 'package:barback/barback.dart';
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';
import 'package:source_span/source_span.dart' show SourceFile;
import 'package:source_maps/refactor.dart';


class PygmentsTransformer extends Transformer {
  final BarbackSettings _settings;

  PygmentsTransformer.asPlugin(this._settings);

  String get allowedExtensions => '.html';

  Future apply(Transform transform) async {
    var contents = await transform.primaryInput.readAsString();
    var doc = parse(contents, generateSpans: true);
    var rewriter = new TextEditTransaction(contents,
                                           new SourceFile.fromString(contents));
    var hasMatches = false;
    var unescape = new HtmlUnescape();

    for (var cls in _settings.configuration['classes']) {
      var query = cls.keys.first;
      var opts = cls.values.first;

      var pattern;
      var doUnescape = true;
      if (opts is String) {
        pattern = opts;
      } else {
        pattern = opts.containsKey('re') ? new RegExp(opts['re']) : opts['lang'];
        if (opts.containsKey('unescape') && !opts['unescape']) {
          doUnescape = false;
        }
      }

      var matches = doc.querySelectorAll(query);

      if (!matches.isEmpty) {
        hasMatches = true;
      }

      for (var match in matches) {
        var code;

        if (match.children.length == 1 && match.children[0].localName == 'code') {
          code = match.children[0].innerHtml;
        } else {
          code = match.innerHtml;
        }

        var lang;

        if (pattern is String) {
          lang = pattern;
        } else {
          for (var cls in match.classes) {
            var m = pattern.firstMatch(cls);
            if (m != null) {
              lang = m.group(1);
              break;
            }
          }
        }

        if (doUnescape) {
          print(code);
          code = unescape.convert(code);
        }

        var proc = await Process.start('pygmentize', ['-l', lang, '-f', 'html']);
        proc.stdin.write(code);
        await proc.stdin.flush();
        await proc.stdin.close();
        var formattedCode = await proc.stdout
                                    .map((bytes) => new String.fromCharCodes(bytes))
                                    .join();

        rewriter.edit(match.sourceSpan.start.offset, match.endSourceSpan.end.offset,
                      formattedCode);
      }
    }

    if (hasMatches) {
      var printer = rewriter.commit();
      printer.build(null);
      transform.addOutput(new Asset.fromString(transform.primaryInput.id, printer.text));
    } else {
      transform.addOutput(transform.primaryInput);
    }
  }
}

