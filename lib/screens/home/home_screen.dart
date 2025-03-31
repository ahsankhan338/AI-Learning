import 'dart:io';

import 'package:aieducator/api/categories_api.dart';
import 'package:aieducator/constants/constants.dart';
import 'package:aieducator/models/category_modal.dart';
import 'package:aieducator/utility/data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    print("fetched:");
    try {
      final fetchedCategories =
          await CategoriesApi.get3Categories(token: "token!");
      print("fetched: $fetchedCategories");
      setState(() {
        _categories = fetchedCategories;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  final double constHeight = 20.0;

  String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:3001";
    } else {
      return "http://localhost:3001";
    }
  }

  @override
  Widget build(BuildContext context) {
    print("_categories: $_categories");
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchBar(
                hintText: "Search",
                padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 20)),
                trailing: [Icon(Icons.search)],
              ),
              SizedBox(
                height: constHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recommended",
                    style: AppTextStyles.bodyTitle(),
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        "See All",
                        style: AppTextStyles.textButtonStyle(),
                      ))
                ],
              ),
              SizedBox(
                height: constHeight,
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _categories.map((item) {
                    final String imageURL = item.imageUrl
                        .toString()
                        .replaceFirst(
                            "http://localhost:3001", "http://10.0.2.2:3001");

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () {
                            context.goNamed(
                              'courseDetail',
                              pathParameters: {
                                'name': item.title,
                                'categoryId': item.uuid.toString()
                              },
                            );
                          },
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.start, // Distribute space
                            children: [
                              // Text(item.toString()),
                              Expanded(
                                flex: 2,
                                child: Image.network(
                                  imageURL,
                                  height: 95,
                                  width: 95,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(item.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 2, // Prevent excessive height
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          AppTextStyles.textLabelSmallStyle()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: constHeight + constHeight + constHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Course In Progress",
                    style: AppTextStyles.bodyTitle(),
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        "See All",
                        style: AppTextStyles.textButtonStyle(),
                      ))
                ],
              ),
              SizedBox(
                height: constHeight,
              ),
              ..._categories.map(
                (e) => Container(),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: courseInProgress.map((item) {
                    return Expanded(
                      // Equal width for all columns
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () {
                            context.goNamed(
                              'courseDetail',
                              pathParameters: {'name': item['title'] ?? ''},
                            );
                          },
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.start, // Distribute space
                            children: [
                              Expanded(
                                flex: 2,
                                child: Image.asset(
                                  item['icon']!,
                                  height: 75,
                                  width: 75,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    item['title']!,
                                    textAlign: TextAlign.center,
                                    maxLines: 2, // Prevent excessive height
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.textLabelSmallStyle(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: constHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
