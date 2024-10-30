import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/utils/color.dart';
import 'package:support/screen/wallet/wallet_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/screen/home/helper_detail_screen.dart';
import 'package:support/utils/comment_words.dart';
import 'package:share_plus/share_plus.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class OptionsScreen extends StatefulWidget {
  final String image;
  final String name;
  final String reelId;
  final int listnerId;
  final String caption;
  final int index;
  final XFile thumbnailImage;

  const OptionsScreen({
    super.key,
    required this.image,
    required this.name,
    required this.reelId,
    required this.listnerId,
    required this.caption,
    required this.index,
    required this.thumbnailImage,
  });

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  List<dynamic> likesList = [];
  List<dynamic> comments = [];
  bool fetchingLikes = false;
  bool isLiked = false;
  bool toggle = false;
  bool fetchingComments = false;
  bool updatingComments = false;
  bool isListener = false;
  String image = '';
  final TextEditingController commentController = TextEditingController();
  bool fetchingLikesAndComments = false;
  bool fetchingViews = false;
  int viewCount = 0;
  bool isReplying = false;
  String commentId = '';
  String userName = '';
  FocusNode focusNode = FocusNode();
  String selectedComment = 'Comment will appear here...';
  int selectedPrice = 100;
  String itemName = '';
  int amount = 0;
  int likeCount = 0;
  int commentCount = 0;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    checkListener();
    fetchLikesAndComments();
  }

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setProfilePic(isListener);
    setState(() {});
  }

  void setProfilePic(bool isListener) {
    if (isListener) {
      setState(() {
        image =
            '${APIConstants.BASE_URL}${SharedPreference.getValue(PrefConstants.LISTENER_IMAGE)}';
      });
    } else {
      setState(() {
        image = SharedPreference.getValue(PrefConstants.USER_IMAGE);
      });
    }
  }

  void fetchLikesAndComments() async {
    fetchingLikesAndComments = true;
    fetchingViews = true;
    await APIServices.updateViews(
      widget.reelId,
      int.parse(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      ),
    );
    final response = await APIServices.fetchCommentsAndLikes(widget.reelId);

    final viewsList = response['views'];
    comments = response['comments'] ?? [];
    likesList = response['likes'] ?? [];

    for (int i = 0; i < comments.length; i++) {
      String userId = comments[i]['id'].toString();
      if (comments[i]['type'] == 'user') {
        var userData = await APIServices.getUserDataById(userId);
        comments[i]['image'] = userData.data![0].image;
      } else {
        ListnerDisplayModel listnerDisplayModel =
            await APIServices.getListnerDataById(userId);
        comments[i]['image'] =
            '${APIConstants.BASE_URL}${listnerDisplayModel.data![0].image}';
      }
    }
    for (int i = 0; i < comments.length; i++) {
      if (comments[i]['reply'].length != 0) {
        String userId = comments[i]['reply'][0]['id'].toString();
        if (comments[i]['reply'][0]['type'] == 'user') {
          var userData = await APIServices.getUserDataById(userId);
          comments[i]['reply'][0]['image'] = userData.data![0].image;
        } else {
          ListnerDisplayModel listnerDisplayModel =
              await APIServices.getListnerDataById(userId);
          comments[i]['reply'][0]['image'] =
              '${APIConstants.BASE_URL}${listnerDisplayModel.data![0].image}';
        }
      }
    }
    setState(() {
      isLiked = likesList.contains(
        int.parse(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
        ),
      );
      likeCount = likesList.length;
      commentCount = comments.length;
      viewCount = viewsList?.length ?? 0;
      fetchingLikesAndComments = false;
      fetchingViews = false;
    });
  }

  void fetchLikes() async {
    setState(() {
      fetchingLikes = true;
    });
    final response = await APIServices.fetchCommentsAndLikes(widget.reelId);
    setState(() {
      likesList = response['likes'] ?? [];
      isLiked = likesList.contains(
        int.parse(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
        ),
      );
      likeCount = likesList.length;
      fetchingLikes = false;
    });
  }

  void fetchComments() async {
    setState(() {
      fetchingComments = true;
    });
    final response = await APIServices.fetchCommentsAndLikes(widget.reelId);
    comments = response['comments'] ?? [];

    for (int i = 0; i < comments.length; i++) {
      String userId = comments[i]['id'].toString();
      if (comments[i]['type'] == 'user') {
        var userData = await APIServices.getUserDataById(userId);
        comments[i]['image'] = userData.data![0].image;
      } else {
        ListnerDisplayModel listnerDisplayModel =
            await APIServices.getListnerDataById(userId);
        comments[i]['image'] =
            '${APIConstants.BASE_URL}${listnerDisplayModel.data![0].image}';
      }
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['reply'].length != 0) {
          String userId = comments[i]['reply']['id'].toString();
          if (comments[i]['reply'][0]['type'] == 'user') {
            var userData = await APIServices.getUserDataById(userId);
            comments[i]['reply'][0]['image'] = userData.data![0].image;
          } else {
            ListnerDisplayModel listnerDisplayModel =
                await APIServices.getListnerDataById(userId);
            comments[i]['reply'][0]['image'] =
                '${APIConstants.BASE_URL}${listnerDisplayModel.data![0].image}';
          }
        }
      }
    }
    setState(() {
      // commentCount = comments.length;
      fetchingComments = false;
    });
  }

  void toggleLike() async {
    setState(() {
      toggle = true;
      isLiked = !isLiked;
      if (isLiked) {
        likeCount++;
      } else {
        likeCount--;
      }
    });
    final response = await APIServices.toggleLike(
      widget.reelId,
      int.parse(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      ),
    );
    if (response == 200) {
      fetchLikes();
      await Future.delayed(const Duration(milliseconds: 1600));
      setState(() {
        toggle = false;
      });
    }
  }

  void postReply(
      String reelId, String commentId, int userId, String reply) async {
    if (reply != "") {
      setState(() {
        updatingComments = true;
        commentCount++;
      });
      await APIServices.postReply(reelId, commentId, userId, reply);
      fetchComments();
      setState(() {
        updatingComments = false;
      });
    } else {
      EasyLoading.showError('Enter Reply'.tr);
    }
  }

  void postComment(String reelId, int userId, String content) async {
    if (content == 'Comment will appear here...') {
      EasyLoading.showError('Please select Comment'.tr);
    } else {
      setState(() {
        updatingComments = true;
      });
      String message =
          await APIServices.postReelComment(reelId, userId, content);
      if (message != "success") {
        EasyLoading.showError(message);
      } else {
        fetchComments();
      }
      setState(() {
        updatingComments = false;
      });
    }
  }

  Widget commentChild(List data) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25.0, bottom: 20),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: colorWhite,
                  ),
                ),
                const Spacer(),
                Text(
                  'Support Comments'.tr,
                  style: const TextStyle(
                    color: colorWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Container(
              color: colorWhite,
              height: 0.4,
              width: 350,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: comments[i]['image'],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  color: Color.fromRGBO(56, 52, 52, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 14, top: 5, bottom: 5, right: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data[i]['name'],
                                        style: const TextStyle(
                                            color: colorWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        data[i]['content'],
                                        style: const TextStyle(
                                          color: colorWhite,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isListener
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 60.0, top: 4),
                              child: data[i]['reply'].length == 0
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isReplying = true;
                                          userName = data[i]['name'];
                                          commentId = data[i]['commentId'];
                                        });
                                      },
                                      child: const Text(
                                        'Reply',
                                        style: TextStyle(
                                          color: colorWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            )
                          : Container(),
                      data[i]['reply'].length != 0
                          ? const Padding(
                              padding: EdgeInsets.only(left: 65.0),
                              child: Text(
                                '|_',
                                style:
                                    TextStyle(color: colorWhite, fontSize: 20),
                              ),
                            )
                          : const SizedBox(
                              height: 10,
                            ),
                      Padding(
                        padding: const EdgeInsets.only(left: 80),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            data[i]['reply'].length != 0
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: CircleAvatar(
                                      radius: 16,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: data[i]['reply'][0]
                                              ['image'],
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                color: Color.fromRGBO(56, 52, 52, 1),
                              ),
                              child: data[i]['reply'].length != 0
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 14,
                                          top: 5,
                                          bottom: 5,
                                          right: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data[i]['reply'][0]['name'],
                                            style: const TextStyle(
                                                color: colorWhite,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          Text(
                                            data[i]['reply'][0]['content'],
                                            style: const TextStyle(
                                              color: colorWhite,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              bottom: 12.0,
            ),
            child: Column(
              children: [
                isReplying
                    ? Row(
                        children: [
                          if (isReplying)
                            const SizedBox(
                              width: 5,
                            ),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Replying to ',
                                  style: TextStyle(
                                    color: colorWhite,
                                  ),
                                ),
                                TextSpan(
                                  text: '$userName    .',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorWhite,
                                  ),
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isReplying = false;
                                selectedComment = 'Comment will appear here...';
                              });
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: colorWhite,
                            ),
                            iconSize: 18,
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: comment.length,
                    itemBuilder: (BuildContext context, int index) {
                      final displayText = isReplying ? reply : comment;
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 6.0,
                          bottom: 8,
                          right: 10,
                        ), // Adjust spacing as needed
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: colorWhite),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor:
                                const Color.fromRGBO(56, 52, 52, 1),
                          ),
                          onPressed: () {
                            setState(
                              () {
                                selectedComment = displayText[index];
                              },
                            );
                          },
                          child: Text(displayText[index]),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorWhite,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(
                            selectedComment,
                            style: const TextStyle(
                              color: colorWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    IconButton(
                      onPressed: () {
                        isReplying
                            ? postReply(
                                widget.reelId,
                                commentId,
                                int.parse(
                                  SharedPreference.getValue(
                                      PrefConstants.MERA_USER_ID),
                                ),
                                selectedComment,
                              )
                            : postComment(
                                widget.reelId,
                                int.parse(
                                  SharedPreference.getValue(
                                      PrefConstants.MERA_USER_ID),
                                ),
                                selectedComment);
                        setState(() {
                          isReplying = false;
                          commentController.clear();
                          selectedComment = 'Comment will appear here...';
                        });
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.send,
                        size: 30,
                        color: colorWhite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(String itemName, int amount, double height) {
    return GestureDetector(
      onTap: () async {
        // Show dialog asking for confirmation before proceeding
        showDialog(
          context: context,
          builder: (BuildContext contxt) {
            return AlertDialog(
              elevation: 1,
              title: const Text('Reels Gift'),
              content: Text(
                  'Are you sure you want to send Gift $itemName with price $amount ?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(contxt).pop();
                  },
                ),
                TextButton(
                    child: const Text('Yes'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Navigator.of(contxt).pop();
                      String? userBalance = await APIServices.getWalletAmount(
                          SharedPreference.getValue(
                              PrefConstants.MERA_USER_ID));

                      // Check if user balance is less than the gift amount
                      if (double.parse(userBalance!) <= amount) {
                        // Show dialog indicating insufficient balance
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            margin: const EdgeInsets.only(
                                left: 10, bottom: 10, right: 10),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: colorWhite,
                            content: Text(
                                'Your balance is insufficient to send this gift. Please recharge your account.'
                                    .tr,
                                style: const TextStyle(color: colorBlack)),
                            action: SnackBarAction(
                              label: 'Recharge Now'.tr,
                              textColor: primaryColor,
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletScreen(
                                              isFromReels: true,
                                            )));
                              },
                            ),
                          ));
                        }
                      } else {
                        EasyLoading.show(status: 'loading'.tr);
                        bool? result = await APIServices.sendGift(
                          fromId: int.parse(
                            SharedPreference.getValue(
                                PrefConstants.MERA_USER_ID),
                          ),
                          toId: widget.listnerId,
                          amount: amount,
                          reelId: widget.reelId,
                          gift: itemName,
                        );
                        if (result!) {
                          EasyLoading.dismiss();
                          EasyLoading.showSuccess('Gift Sent!!'.tr);
                        }
                      }
                    }),
              ],
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: colorWhite),
                color: const Color.fromARGB(255, 75, 73, 73),
                borderRadius: const BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              height: 25,
              width: 50,
              child: Center(
                child: Text(
                  "₹$amount",
                  style: const TextStyle(
                    color: colorWhite,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSack(
    String itemName,
    List<int> prices,
    double height,
    int selectedPrice,
  ) {
    return StatefulBuilder(
      builder: (context, setState) => GestureDetector(
        onTap: () async {
          // Show dialog asking for confirmation before proceeding
          showDialog(
            context: context,
            builder: (BuildContext contxt) {
              return AlertDialog(
                elevation: 1,
                title: const Text('Reels Gift'),
                content: Text(
                    'Are you sure you want to send Gift $itemName with price $selectedPrice ?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(contxt).pop();
                    },
                  ),
                  TextButton(
                      child: const Text('Yes'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.of(contxt).pop();
                        String? userBalance = await APIServices.getWalletAmount(
                            SharedPreference.getValue(
                                PrefConstants.MERA_USER_ID));

                        // Check if user balance is less than the gift amount
                        if (double.parse(userBalance!) <= amount) {
                          // Show dialog indicating insufficient balance
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              margin: const EdgeInsets.only(
                                  left: 10, bottom: 10, right: 10),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: colorWhite,
                              content: Text(
                                  'Your balance is insufficient to send this gift. Please recharge your account.'
                                      .tr,
                                  style: const TextStyle(color: colorBlack)),
                              action: SnackBarAction(
                                label: 'Recharge Now'.tr,
                                textColor: primaryColor,
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const WalletScreen(
                                                isFromReels: true,
                                              )));
                                },
                              ),
                            ));
                          }
                        } else {
                          EasyLoading.show(status: 'loading'.tr);
                          bool? result = await APIServices.sendGift(
                            fromId: int.parse(
                              SharedPreference.getValue(
                                  PrefConstants.MERA_USER_ID),
                            ),
                            toId: widget.listnerId,
                            amount: selectedPrice,
                            reelId: widget.reelId,
                            gift: itemName,
                          );
                          if (result!) {
                            EasyLoading.dismiss();
                            EasyLoading.showSuccess('Gift Sent!!'.tr);
                          }
                        }
                      }),
                ],
              );
            },
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: colorWhite),
                color: const Color.fromARGB(255, 75, 73, 73),
                borderRadius: const BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              height: 25,
              width: 70,
              child: DropdownButton<int>(
                alignment: Alignment.center,
                value: selectedPrice,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedPrice = newValue!;
                  });
                  debugPrint(selectedPrice.toString());
                },
                items: prices.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Center(
                      child: Text(
                        '₹$value',
                        style: const TextStyle(color: colorWhite),
                      ),
                    ),
                  );
                }).toList(),
                dropdownColor: const Color.fromARGB(255, 75, 73, 73),
                style: const TextStyle(color: colorWhite),
                underline: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
        left: 10,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  if (mounted) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HelperDetailScreen(
                              listnerId: widget.listnerId.toString(),
                              showFeedbackForm: false,
                            )));
                  }
                },
                child: Row(
                  children: [
                    showImage(
                      20,
                      widget.image.startsWith('https://')
                          ? NetworkImage(widget.image)
                          : NetworkImage(
                              '${APIConstants.BASE_URL}${widget.image}'),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.name,
                      style: const TextStyle(
                          color: colorWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Text(
                    widget.caption != '' ? widget.caption : '',
                    style: const TextStyle(color: colorWhite),
                    softWrap: true,
                    maxLines: 2,
                  ),
                ),
              ),
              if (!isListener) ...{
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) => Container(
                            height: 240,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(40, 36, 36, 1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Text(
                                    'Send a gift'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorWhite,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  color: colorWhite,
                                  height: 0.4,
                                  width: 350,
                                ),
                                Expanded(
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      buildItem("🌹", 50, 100),
                                      buildItem("🍫", 100, 100),
                                      buildItem("🎁", 150, 90),
                                      buildItem("🎂", 200, 80),
                                      buildItem("👑", 250, 80),
                                      buildItem("🧸", 300, 80),
                                      buildItem("💎", 350, 80),
                                      buildSack(
                                          "💰",
                                          [100, 200, 300, 400, 500, 1000],
                                          20,
                                          selectedPrice),
                                      buildItem("🎸", 400, 80),
                                      buildItem("❤️", 500, 80),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: colorWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorWhite,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.card_giftcard_rounded,
                            color: colorWhite,
                            size: 20,
                          ),
                          Text(
                            ' send gift'.tr,
                            style: const TextStyle(
                                color: colorWhite, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              },
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Share.shareXFiles(
                        [widget.thumbnailImage],
                        text:
                            // 'Check out this reel by ${widget.name}!!\n\nsupportletstalk.com/reels?index=${widget.index}&listenerId=${widget.listnerId}',
                            'Check out this reel by ${widget.name}!!\n\nhttps://supportletstalk.page.link/start',
                      );
                    },
                    child: Transform(
                      transform: Matrix4.rotationZ(0),
                      child: const Icon(
                        Icons.send,
                        color: colorWhite,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              fetchingViews
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: colorWhite,
                        size: 24,
                      ),
                    )
                  : Column(
                      children: [
                        const Icon(
                          Icons.remove_red_eye_outlined,
                          color: colorWhite,
                          size: 30,
                        ),
                        Text(
                          '$viewCount',
                          style: const TextStyle(color: colorWhite),
                        ),
                      ],
                    ),
              const SizedBox(height: 10),
              // fetchingLikes ||toggle ||
              fetchingLikesAndComments
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: colorWhite,
                        size: 24,
                      ),
                    )
                  : Column(
                      children: [
                        GestureDetector(
                          onTap: toggleLike,
                          child: isLiked
                              ? const Icon(
                                  Icons.favorite,
                                  color: colorRed,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.favorite_outline,
                                  color: colorRed,
                                  size: 30,
                                ),
                        ),
                        Text(
                          likeCount.toString(),
                          //'${likesList.length}',
                          style: const TextStyle(color: colorWhite),
                        ),
                      ],
                    ),
              const SizedBox(height: 10),
              // fetchingComments ||
              //         updatingComments ||
              fetchingLikesAndComments
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: colorWhite,
                        size: 24,
                      ),
                    )
                  : Column(
                      children: [
                        GestureDetector(
                          child: const Icon(Icons.comment,
                              color: colorWhite, size: 30),
                          onTap: () {
                            setState(() {
                              selectedComment = 'Comment will appear here...';
                            });
                            showModalBottomSheet<dynamic>(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) => Container(
                                    height: height * 0.8,
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(40, 36, 36, 1),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: commentChild(comments),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        Text(
                          '${comments.length}',
                          //commentCount.toString(),
                          style: const TextStyle(color: colorWhite),
                        ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
