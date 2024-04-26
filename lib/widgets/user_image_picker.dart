import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

File? _pickedImage;

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onSelectImage});

  final void Function(File pickedImage) onSelectImage;

  @override
  State<StatefulWidget> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  void _chooseAnImage() async {
    var choosenImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 60, imageQuality: 50);
    if (choosenImage == null) {
      return;
    }
    setState(() {
      _pickedImage = File(choosenImage.path);
    });
    widget.onSelectImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
            onPressed: _chooseAnImage,
            icon: const Icon(Icons.image),
            label: const Text('Select an image'))
      ],
    );
  }
}
