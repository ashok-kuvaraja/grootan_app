import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../const.dart';
import '../widgets/common.dart';
import '../model/user_details.dart';
import '../view_model/last_login_view_mode.dart';

class LastLoginPage extends StatelessWidget {
  const LastLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GrootanAppPage(
      pageTitle: 'Last Login',
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: canvasColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: AppBar(
              backgroundColor: canvasColor,
              automaticallyImplyLeading: false,
              bottom: TabBar(
                indicatorColor: Colors.white,
                isScrollable: true,
                tabs: LastLoginViewModel.instance.pages
                    .map((name) => Tab(text: name))
                    .toList(),
              ),
            ),
          ),
          body: TabBarView(
            children: LastLoginViewModel.instance.pages
                .map((name) => showUserDetails(name))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget showUserDetails(String day) {
    final LastLoginViewModel model = LastLoginViewModel.instance;
    return StreamBuilder(
      stream: model.getUserDetailsAsStream(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final List<UserDetails> userDocument =
              model.filterUserDetails(snapshot, day);

          return Visibility(
            visible: userDocument.isNotEmpty,
            replacement: const Center(
              child: Text(
                'No Data Available',
                style: TextStyle(color: defaultTextColor),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: userDocument.length,
                itemBuilder: (context, index) {
                  return _buildListTile(context, userDocument[index]);
                },
              ),
            ),
          );
        } else {
          return const SizedProgressIndicator();
        }
      },
    );
  }

  Widget _buildListTile(BuildContext context, UserDetails userDetails) {
    final bool hasQRImage = userDetails.qrCodeURL.isNotEmpty;
    final String time =
        DateFormat("h:mm a").format(DateTime.parse(userDetails.time));

    Widget buildPlaceholder(BuildContext context, String url) {
      return const SizedProgressIndicator();
    }

    return SizedBox(
      height: 100.0,
      child: Stack(
        children: [
          Positioned.fill(
            left: 0.0,
            bottom: 0.0,
            top: 10.0,
            child: Card(
              color: tileBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: SizedBox(
                    height: 80.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(time),
                        Text('IP: ${userDetails.userIP}'),
                        Text(userDetails.city),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (hasQRImage)
            Positioned(
              right: 0.0,
              bottom: 0.0,
              width: 100.0,
              height: 100.0,
              child: Card(
                color: qrCardColor,
                child: CachedNetworkImage(
                  imageUrl: userDetails.qrCodeURL,
                  placeholder: buildPlaceholder,
                ),
              ),
            )
        ],
      ),
    );
  }
}
