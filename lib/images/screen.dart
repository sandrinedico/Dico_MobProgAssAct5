import 'package:flutter/material.dart';
import 'package:mobprogass_act5/images/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:provider/provider.dart';


class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> with WidgetsBindingObserver {
  late final ImageModel _model;
  bool _detectPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    _model = ImageModel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _detectPermission &&
        (_model.imageSection == ImageSection.noStoragePermissionPermanent)) {
      _detectPermission = false;
      _model.requestFilePermission();
    } else if (state == AppLifecycleState.paused &&
        _model.imageSection == ImageSection.noStoragePermissionPermanent) {
      _detectPermission = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<ImageModel>(
        builder: (context, model, child) {
          Widget widget;

          switch (model.imageSection) {
            case ImageSection.noStoragePermission:
              widget = ImagePermissions(
                  isPermanent: false, onPressed: _checkPermissionsAndPick);
              break;
            case ImageSection.noStoragePermissionPermanent:
              widget = ImagePermissions(
                  isPermanent: true, onPressed: _checkPermissionsAndPick);
              break;
            case ImageSection.browseFiles:
              widget = PickFile(onPressed: _checkPermissionsAndPick);
              break;
            case ImageSection.imageLoaded:
              widget = ImageLoaded(file: _model.file!);
              break;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('File Image Storage',
                style: TextStyle(
                    fontWeight: FontWeight.bold),
                ),
              centerTitle: true,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                    colors: <Color>[Color(0xFFF8BBD0), Color(0xFFC5CAE9)]),
                  ),
                ),
            ),
            body: widget,
          );
        },
      ),
    );
  }

  Future<void> _checkPermissionsAndPick() async {
    final hasFilePermission = await _model.requestFilePermission();
    if (hasFilePermission) {
      try {
        await _model.pickFile();
      } on Exception catch (e) {
        debugPrint('Error when picking a file: $e');
        // Show an error to the user if the pick file failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred when picking a file'),
          ),
        );
      }
    }
  }
}


class ImagePermissions extends StatelessWidget {
  final bool isPermanent;
  final VoidCallback onPressed;

  const ImagePermissions({
    Key? key,
    required this.isPermanent,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: Text(
              'Read files permission',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: const Text(
              'Need to request your permission to read '
                  'Local Files in order to load it in the app.',
              textAlign: TextAlign.center,
            ),
          ),
          if (isPermanent)
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: const Text(
                'Need to give this permission from the system settings.',
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            padding: const EdgeInsets.only(
                left: 16.0, top: 24.0, right: 16.0, bottom: 24.0),
            child: ElevatedButton(
              child: Text(isPermanent ? 'Open settings' : 'Allow access'),
              onPressed: () => isPermanent ? openAppSettings() : onPressed(),
            ),
          ),
        ],
      ),
    );
  }
}

class PickFile extends StatelessWidget {
  final VoidCallback onPressed;

  const PickFile({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      child: Text('Choose an Image',
        style: TextStyle(
            fontSize: 30,
          fontWeight: FontWeight.bold,
            foreground: Paint()..shader = LinearGradient(colors: <Color>[
              Color(0xFFF8BBD0),
              Color(0xFFE0F7FA),
              Color(0xFFE1BEE7)
             ],
            ).createShader(Rect.fromLTWH(0,  50, 150, 200))
         )
        ),
      onPressed: onPressed,
    ),
  );
}

class ImageLoaded extends StatelessWidget {
  final File file;

  const ImageLoaded({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: ClipOval(
          child: Image.file(
            file,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}


