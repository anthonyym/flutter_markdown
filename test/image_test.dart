// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'image_test_mocks.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Image', () {
    setUp(() {
      // Only needs to be done once since the HttpClient generated
      // by this override is cached as a static singleton.
      io.HttpOverrides.global = TestHttpOverrides();
    });

    testWidgets(
      'should not interrupt styling',
      (WidgetTester tester) async {
        const String data = '_textbefore ![alt](https://img) textafter_';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final Iterable<RichText> texts =
            tester.widgetList(find.byType(RichText));
        final RichText firstTextWidget = texts.first;
        final TextSpan firstTextSpan = firstTextWidget.text as TextSpan;
        final Image image = tester.widget(find.byType(Image));
        final NetworkImage networkImage = image.image as NetworkImage;
        final RichText secondTextWidget = texts.last;
        final TextSpan secondTextSpan = secondTextWidget.text as TextSpan;

        expect(firstTextSpan.text, 'textbefore ');
        expect(firstTextSpan.style!.fontStyle, FontStyle.italic);
        expect(networkImage.url, 'https://img');
        expect(secondTextSpan.text, ' textafter');
        expect(secondTextSpan.style!.fontStyle, FontStyle.italic);
      },
    );

    testWidgets(
      'should work with a link',
      (WidgetTester tester) async {
        const String data = '![alt](https://img#50x50)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final Image image = tester.widget(find.byType(Image));
        final NetworkImage networkImage = image.image as NetworkImage;
        expect(networkImage.url, 'https://img');
        expect(image.width, 50);
        expect(image.height, 50);
      },
    );

    testWidgets(
      'should work with relative remote image',
      (WidgetTester tester) async {
        const String data = '![alt](/img.png)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(
              data: data,
              imageDirectory: 'https://localhost',
            ),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        final Image image =
            widgets.firstWhere((Widget widget) => widget is Image) as Image;

        expect(image.image is NetworkImage, isTrue);
        expect((image.image as NetworkImage).url, 'https://localhost/img.png');
      },
    );

    testWidgets(
      'local files should be files',
      (WidgetTester tester) async {
        const String data = '![alt](http.png)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        final Image image =
            widgets.firstWhere((Widget widget) => widget is Image) as Image;

        expect(image.image is FileImage, isTrue);
      },
    );

    testWidgets(
      'should work with resources',
      (WidgetTester tester) async {
        const String data = '![alt](resource:assets/logo.png)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        final Image image =
            widgets.firstWhere((Widget widget) => widget is Image) as Image;

        expect(image.image is AssetImage, isTrue);
        expect((image.image as AssetImage).assetName, 'assets/logo.png');
      },
    );

    testWidgets(
      'should work with local image files',
      (WidgetTester tester) async {
        const String data = '![alt](img.png#50x50)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final Image image = tester.widget(find.byType(Image));
        final FileImage fileImage = image.image as FileImage;
        expect(fileImage.file.path, 'img.png');
        expect(image.width, 50);
        expect(image.height, 50);
      },
    );

    testWidgets(
      'should show properly next to text',
      (WidgetTester tester) async {
        const String data = 'Hello ![alt](img#50x50)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(data: data),
          ),
        );

        final RichText richText = tester.widget(find.byType(RichText));
        TextSpan textSpan = richText.text as TextSpan;
        expect(textSpan.text, 'Hello ');
        expect(textSpan.style, isNotNull);
      },
    );

    testWidgets(
      'should work when nested in a link',
      (WidgetTester tester) async {
        final List<String> tapTexts = <String>[];
        final List<String?> tapResults = <String?>[];
        const String data = '[![alt](https://img#50x50)](href)';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (text, value, title) {
                tapTexts.add(text);
                tapResults.add(value);
              },
            ),
          ),
        );

        final GestureDetector detector =
            tester.widget(find.byType(GestureDetector));
        detector.onTap!();

        expect(tapTexts.length, 1);
        expect(tapTexts, everyElement('alt'));
        expect(tapResults.length, 1);
        expect(tapResults, everyElement('href'));
      },
    );

    testWidgets(
      'should work when nested in a link with text',
      (WidgetTester tester) async {
        final List<String> tapTexts = <String>[];
        final List<String?> tapResults = <String?>[];
        const String data =
            '[Text before ![alt](https://img#50x50) text after](href)';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (text, value, title) {
                tapTexts.add(text);
                tapResults.add(value);
              },
            ),
          ),
        );

        final GestureDetector detector =
            tester.widget(find.byType(GestureDetector));
        detector.onTap!();

        final Iterable<RichText> texts =
            tester.widgetList(find.byType(RichText));
        final RichText firstTextWidget = texts.first;
        final TextSpan firstSpan = firstTextWidget.text as TextSpan;
        (firstSpan.recognizer as TapGestureRecognizer).onTap!();

        final RichText lastTextWidget = texts.last;
        final TextSpan lastSpan = lastTextWidget.text as TextSpan;
        (lastSpan.recognizer as TapGestureRecognizer).onTap!();

        expect(firstSpan.children, null);
        expect(firstSpan.text, 'Text before ');
        expect(firstSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

        expect(lastSpan.children, null);
        expect(lastSpan.text, ' text after');
        expect(lastSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

        expect(tapTexts.length, 3);
        expect(tapTexts, everyElement('Text before alt text after'));
        expect(tapResults.length, 3);
        expect(tapResults, everyElement('href'));
      },
    );

    testWidgets(
      'should work alongside different links',
      (WidgetTester tester) async {
        final List<String> tapTexts = <String>[];
        final List<String?> tapResults = <String?>[];
        const String data =
            '[Link before](firstHref)[![alt](https://img#50x50)](imageHref)[link after](secondHref)';

        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (text, value, title) {
                tapTexts.add(text);
                tapResults.add(value);
              },
            ),
          ),
        );

        final Iterable<RichText> texts =
            tester.widgetList(find.byType(RichText));
        final RichText firstTextWidget = texts.first;
        final TextSpan firstSpan = firstTextWidget.text as TextSpan;
        (firstSpan.recognizer as TapGestureRecognizer).onTap!();

        final GestureDetector detector =
            tester.widget(find.byType(GestureDetector));
        detector.onTap!();

        final RichText lastTextWidget = texts.last;
        final TextSpan lastSpan = lastTextWidget.text as TextSpan;
        (lastSpan.recognizer as TapGestureRecognizer).onTap!();

        expect(firstSpan.children, null);
        expect(firstSpan.text, 'Link before');
        expect(firstSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

        expect(lastSpan.children, null);
        expect(lastSpan.text, 'link after');
        expect(lastSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

        expect(tapTexts.length, 3);
        expect(tapTexts, ['Link before', 'alt', 'link after']);
        expect(tapResults.length, 3);
        expect(tapResults, ['firstHref', 'imageHref', 'secondHref']);
      },
    );

    testWidgets(
      'custom image builder',
      (WidgetTester tester) async {
        const String data = '![alt](https://img.png)';
        final MarkdownImageBuilder builder =
            (_, __, ___) => Image.asset('assets/logo.png');

        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              imageBuilder: builder,
            ),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        final Image image =
            widgets.firstWhere((Widget widget) => widget is Image) as Image;

        expect(image.image.runtimeType, AssetImage);
        expect((image.image as AssetImage).assetName, 'assets/logo.png');
      },
    );
  });
}
