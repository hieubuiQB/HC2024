import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/bil_services.dart';
import '../../utils/app_widget.dart';
import '../../widgets/bottomnavbar.dart';

class BillPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final int totalPrice;
  final String address;

  const BillPage(
      {super.key,
      required this.orderItems,
      required this.totalPrice,
      required this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hóa Đơn',
          style: AppWidget.HeadlinextFieldStyle(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BotomNavBar()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi tiết món ăn',
              style: AppWidget.HeadlinextFieldStyle(),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index];
                return Card(
                  elevation: 3.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      item['foodName'],
                      style: AppWidget.boldTextFieldStyle(),
                    ),
                    subtitle: Text(
                      'Price: \$${item['price']}, Quantity: ${item['quantity']}',
                      style: AppWidget.LightTextFieldStyle(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Địa chỉ giao hàng:$address',
              style: AppWidget.HeadlinextFieldStyle(),
            ),
            const SizedBox(height: 20),
            Text(
              'Giá thành: \$${totalPrice.toString()}',
              style: AppWidget.HeadlinextFieldStyle(),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    _saveBillToFirestore(context, orderItems, totalPrice);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Thanh toán ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBillToFirestore(BuildContext context,
      List<Map<String, dynamic>> orderItems, int totalPrice) {
    final BillService billService = BillService();
    final Timestamp currentTime = Timestamp.now();
    final Map<String, dynamic> billData = {
      'orderItems': orderItems,
      'totalPrice': totalPrice,
      'time': currentTime,
    };
    billService.saveBill(billData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill saved successfully!'),
          duration: Duration(seconds:1),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save bill. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
