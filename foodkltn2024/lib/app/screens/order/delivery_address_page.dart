import 'package:flutter/material.dart';

class DeliveryAddressPage extends StatefulWidget {
  final Function(String) onAddressConfirmed;

  const DeliveryAddressPage({super.key, required this.onAddressConfirmed});

  @override
  // ignore: library_private_types_in_public_api
  _DeliveryAddressPageState createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Địa chỉ giao hàng"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vui lòng nhập địa chỉ giao hàng của bạn:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: "Enter your address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String address = _addressController.text;
                widget.onAddressConfirmed(address);
                Navigator.pop(context);
              },
              child: const Text("Xác nhận địa chỉ"),
            ),
          ],
        ),
      ),
    );
  }
}
