import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension Extend on Map<String, String> {
  Success? asSuccess() {
    var code = this["code"];
    if (code == null) {
      return null;
    }
    return Success(code: code, state: this["state"]);
  }

  Error? asError() {
    var error = this["code"];
    if (error == null) {
      return null;
    }
    return Error(
      error: error,
      errorDescription: this["error_description"],
      errorUri: this["error_uri"],
      state: this["state"],
    );
  }
}

class Success {
  const Success({
    required this.code,
    this.state,
  });

  final String code;
  final String? state;
}

class Error {
  const Error({
    required this.error,
    this.errorDescription,
    this.errorUri,
    this.state,
  });

  final String error;
  final String? errorDescription;
  final String? errorUri;
  final String? state;
}

void main() {
  var queryParameters = Uri.base.queryParameters;

  runApp(MainApp(
    queryParameters: queryParameters,
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.queryParameters});
  final Map<String, String> queryParameters;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "OAuth Shim",
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("OAuth Shim"),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          alignment: Alignment.center,
          child: Body(queryParameters: queryParameters),
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key, required this.queryParameters});
  final Map<String, String> queryParameters;

  @override
  Widget build(BuildContext context) {
    var success = queryParameters.asSuccess();
    if (success != null) {
      var children = [
        const Text(
            "Copy from below and paste to your initial application to continue authorization flow"),
        space(),
        clipboardButton(
          context,
          "Copy CODE",
          success.code,
          "Authorization code copied",
        )
      ];

      var state = success.state;
      if (state != null) {
        children.addAll([
          space(),
          clipboardButton(
            context,
            "Copy STATE",
            state,
            "Authorization state copied",
          )
        ]);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    var error = queryParameters.asError();
    if (error != null) {
      var description = error.errorDescription;
      var uri = error.errorUri;
      var state = error.state;
      return Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        children: <Widget?>[
          const Text("There was an error in authorization"),
          space(),
          Text("error: ${error.error}"),
          description != null ? Text("description: $description") : null,
          uri != null ? Text("uri: $uri") : null,
          state != null ? Text("state: $state") : null,
        ].whereType<Widget>().toList(),
      );
    }

    return const Text(
      "A simple redirect url for OAuth flows.\n\nWhen a user is redirected to this app, they are given buttons to copy their authorization code (to then paste to your app).",
      textAlign: TextAlign.center,
    );
  }
}

ElevatedButton clipboardButton(
  BuildContext context,
  String buttonLabel,
  String textToCopy,
  String toastContent,
) {
  var scaffoldMessenger = ScaffoldMessenger.of(context);
  return ElevatedButton(
    onPressed: () async {
      Clipboard.setData(ClipboardData(text: textToCopy))
          .then((_) => scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(toastContent),
                  action: SnackBarAction(
                    label: "Dismiss",
                    onPressed: () => scaffoldMessenger.hideCurrentSnackBar(),
                  ),
                ),
              ));
    },
    child: Text(buttonLabel),
  );
}

SizedBox space() {
  return const SizedBox(height: 10);
}
