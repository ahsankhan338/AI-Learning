import 'package:aieducator/api/categories_api.dart';
import 'package:aieducator/constants/constants.dart';
import 'package:aieducator/models/category_modal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Category> _categories = [];
  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      setState(() => _isLoading = true); // <-- start loader

      final fetchedCategories =
          await CategoriesApi.getCategories(token: "token!");
      print("fetched: $fetchedCategories");

      setState(() {
        _categories = fetchedCategories;
        _isLoading = false; // <-- stop loader
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false); // <-- stop loader on error too
    }
  }

  final double constHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    print("_categories: $_categories");
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(), // simple loader
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Availaible Subjects",
                        style: AppTextStyles.bodyTitle(),
                      ),
                    
                    ],
                  ),
                  SizedBox(
                    height: constHeight,
                  ),
                  GridView.count(
                    crossAxisCount: 3, // Show 3 items per row
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevent internal scroll

                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                    children: _categories.map((item) {
                      final String imageURL = item.imageUrl
                          .toString()
                          .replaceFirst(
                              "http://localhost:3001", "http://10.0.2.2:3001");
                      const double size = 62.0;

                      return InkWell(
                        onTap: () {
                          context.goNamed(
                            'courseDetail',
                            pathParameters: {
                              'name': item.title,
                              'categoryId': item.uuid.toString(),
                            },
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size,
                              width: size,
                              child: Image.network(
                                imageURL,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                item.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.textLabelSmallStyle(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // SizedBox(
                  //   height: constHeight * 3,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       "Course In Progress",
                  //       style: AppTextStyles.bodyTitle(),
                  //     ),
                  //     TextButton(
                  //         onPressed: () {},
                  //         child: Text(
                  //           "See All",
                  //           style: AppTextStyles.textButtonStyle(),
                  //         ))
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: constHeight,
                  // ),
                  // IntrinsicHeight(
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                  //     children: courseInProgress.map((item) {
                  //       return Expanded(
                  //         // Equal width for all columns
                  //         child: Container(
                  //           margin: const EdgeInsets.symmetric(horizontal: 4),
                  //           child: InkWell(
                  //             onTap: () {
                  //               context.goNamed(
                  //                 'courseDetail',
                  //                 pathParameters: {'name': item['title'] ?? ''},
                  //               );
                  //             },
                  //             child: Column(
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.start, // Distribute space
                  //               children: [
                  //                 Expanded(
                  //                   flex: 2,
                  //                   child: Image.asset(
                  //                     item['icon']!,
                  //                     height: 75,
                  //                     width: 75,
                  //                     fit: BoxFit.contain,
                  //                   ),
                  //                 ),
                  //                 Flexible(
                  //                   child: Padding(
                  //                     padding: const EdgeInsets.only(top: 8),
                  //                     child: Text(
                  //                       item['title']!,
                  //                       textAlign: TextAlign.center,
                  //                       maxLines: 2, // Prevent excessive height
                  //                       overflow: TextOverflow.ellipsis,
                  //                       style: AppTextStyles.textLabelSmallStyle(),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
                  SizedBox(
                    height: constHeight,
                  ),
                ],
              ),
            ),
          );
  }
}
