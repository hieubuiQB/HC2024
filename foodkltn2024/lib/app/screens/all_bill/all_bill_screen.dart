import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food/app/screens/home/home_screen.dart';
import 'package:intl/intl.dart';

import '../../services/bil_services.dart';
import '../../utils/app_widget.dart';
import '../../widgets/bottomnavbar.dart';

class AllBillsPage extends StatelessWidget {
  final BillService billService = BillService();

  AllBillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Bills',
          style: AppWidget.HeadlinextFieldStyle(),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const BotomNavBar()));
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: billService.getBills(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String foodName = data['orderItems'][0]['foodName'] ?? 'Unknown';

              // Convert timestamp to DateTime object
              DateTime timestamp =
                  (data['time'] as Timestamp).toDate();

              // Format timestamp using DateFormat
              String formattedDate =
                  DateFormat.yMMMd().add_jm().format(timestamp);

              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    'Food: $foodName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price: \$${data['totalPrice']}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Timestamp: $formattedDate',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
