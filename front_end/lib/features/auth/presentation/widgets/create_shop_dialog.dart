import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

class CreateShopDialog extends StatefulWidget {
  final int userId;
  const CreateShopDialog({super.key, required this.userId});

  @override
  State<CreateShopDialog> createState() => _CreateShopDialogState();
}

class _CreateShopDialogState extends State<CreateShopDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Your Shop"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Shop Name")),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            context.read<AuthCubit>().submitShopRequest(
              userId: widget.userId,
              shopName: _nameController.text,
              shopDescription: _descController.text,
            );
            Navigator.pop(context);
          },
          child: const Text("Submit"),
        )
      ],
    );
  }
}