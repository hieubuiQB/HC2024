import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../../services/database.dart';
import '../../services/shared_prefences.dart';
import '../../utils/app_widget.dart';
import '../../widgets/bottomnavbar.dart';
import '../bill/bill_screen.dart';
import '../order/delivery_address_page.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? id, wallet, email;
  late Stream foodStream = const Stream.empty();
  late Timer _timer;
  String? deliveryAddress;

  @override
  void initState() {
    _timer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
      }
    });
    ontheload();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    foodStream = await DatabaseMethods().getFoodCart(id!);
    setState(() {});
  }

  confirmOrderButtonPressed(String address) async {
    String subject = 'Order Confirmation';
    String body = 'Your order has been confirmed!\n\n';

    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(id!)
        .collection('Cart')
        .get();

    List<Map<String, dynamic>> orderItems = [];

    int total = 0;

    cartSnapshot.docs.forEach((doc) async {
      String foodName = doc['Name'];
      String price = doc['Total'];
      String quantity = doc['Quantity'];

      total += int.parse(price);

      body += '$foodName: \$$price x $quantity = \$$price\n';

      int currentQuantity = int.parse(quantity);

      int newQuantity = currentQuantity - 1;
      if (newQuantity <= 0) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id!)
            .collection('Cart')
            .doc(doc.id)
            .delete();
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id!)
            .collection('Cart')
            .doc(doc.id)
            .update({'Quantity': newQuantity.toString()});
      }

      orderItems.add({
        'foodName': foodName,
        'price': price,
        'quantity': quantity,
      });
    });

    DocumentReference orderRef =
        FirebaseFirestore.instance.collection('orders').doc();

    await orderRef.set({
      'userId': id!,
      'orderItems': orderItems,
      'totalPrice': total,
      'address': address,
      'createdAt': Timestamp.now(),
    });

    body += '\nTotal: \$${total.toString()}';

    await sendEmail(email!, subject, body);

    await SharedPreferenceHelper().saveUserPurchaseConfirmed(false);

    await DatabaseMethods().updateFoodCartToPaid(id!);

    await DatabaseMethods().clearUserCart(id!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Order confirmation email sent successfully!",
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillPage(
          orderItems: orderItems,
          totalPrice: total,
          address: address,
        ),
      ),
    );
  }

  sendEmail(String userEmail, String subject, String body) async {
    String username = 'buivanhieuqbdh@gmail.com';
    String password = 'rsch souj suiw xfkn';

    gmail(username, password);


    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Email sent successfully!",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } on MailerException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to send email: ${e.toString()}",
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }

  Widget foodCart() {
    return StreamBuilder(
      stream: foodStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return Container(
                margin: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 10.0,
                ),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          height: 90,
                          width: 40,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text(ds["Quantity"])),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            ds["Image"],
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Column(
                          children: [
                            Text(
                              ds["Name"],
                              style: AppWidget.SemiBoldTextFieldStyle(),
                            ),
                            Text(
                              "\$" + ds["Total"],
                              style: AppWidget.SemiBoldTextFieldStyle(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const BotomNavBar()));
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Material(
                  elevation: 2.0,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Center(
                      child: Text(
                        "Mua món ăn",
                        style: AppWidget.HeadlinextFieldStyle(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 2,
              child: foodCart(),
            ),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tổng tiền",
                    style: AppWidget.boldTextFieldStyle(),
                  ),
                  StreamBuilder(
                    stream: foodStream,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                        return const Text('0');
                      } else {
                        int total = 0;
                        snapshot.data.docs.forEach((doc) {
                          total += int.parse(doc['Total']);
                        });
                        return Text(
                          "\$$total",
                          style: AppWidget.SemiBoldTextFieldStyle(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryAddressPage(
                      onAddressConfirmed: (address) {
                        setState(() {
                          deliveryAddress = address;
                        });
                      },
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: const Center(
                  child: Text(
                    "Địa chỉ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (deliveryAddress != null) {
                  confirmOrderButtonPressed(deliveryAddress!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        "Vui lòng nhập địa chỉ",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: const Center(
                  child: Text(
                    "Confirm Order",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
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
}
