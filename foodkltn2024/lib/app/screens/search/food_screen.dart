import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database.dart';
import '../../utils/app_widget.dart';
import '../../widgets/form_widget.dart';
import '../detail/detail_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  _FoodSearchScreenState createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchFood(String searchText) async {
    if (searchText.isNotEmpty) {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await _databaseMethods.searchFoodByName(searchText);

        if (querySnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> foodData = [];
          for (var foodDoc in querySnapshot.docs) {
            foodData.add(foodDoc.data());
          }
          setState(() {
            _searchResults = foodData;
          });
        } else {
          setState(() {
            _searchResults = [];
          });
          print('No results found for "$searchText"');
        }
      } catch (e) {
        print('Error searching food: $e');
      }
    }
  }

  Widget _buildFoodCard(Map<String, dynamic> foodData) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Details(
                detail: foodData['Detail'],
                image: foodData['Image'],
                name: foodData['Name'],
                price: foodData['Price'],
              ),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(foodData['Image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodData['Name'],
                    style: AppWidget.boldTextFieldStyle(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: \$${foodData['Price']}',
                    style: AppWidget.SemiBoldTextFieldStyle(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FormContainerWidget(
              controller: _searchController,
              hintText: 'Search food',
              prefixIcon: Icons.search,
              onFieldSubmitted: (value) => _searchFood(value),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildFoodCard(_searchResults[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
