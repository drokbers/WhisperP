import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../consts/index.dart';
import '../../../models/user_model.dart';
import 'search_result_card.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final searchText = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 48,
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(),
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => searchText.value = v,
          ),
        ),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: searchText,
        builder: (_, value, __) {
          final List<UserModel> resultList = value.isEmpty
              ? []
              : Hive.box<UserModel>(BoxNames.users)
                  .values
                  .where((e) => e.toString().contains(value))
                  .toList();

          return ListView.builder(
            itemCount: resultList.length,
            itemBuilder: (context, index) {
              return SearchResultCard(user: resultList[index]);
            },
          );
        },
      ),
    );
  }
}
