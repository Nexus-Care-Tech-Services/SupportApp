import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/post_model.dart';
import 'package:support/model/reaction_model.dart';
import 'package:support/screen/user_leaderboard/listner/comment_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class UserPostScreen extends StatefulWidget {
  const UserPostScreen({Key? key}) : super(key: key);

  @override
  UserPostScreenState createState() => UserPostScreenState();
}

class UserPostScreenState extends State<UserPostScreen> {
  List<UserPost>? posts = [];

  bool viewReaction = false;
  List<Reaction> currentReaction = [];
  List<String> postIds = [];
  List<bool> viewReactions = [];
  final int _selectedPostIndex = -1;
  List<int> totalreactions = [];

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      posts = await APIServices.getEmotionalStories() ?? [];
      totalreactions.clear();
      debugPrint("length: ${posts!.length}");
      for (int i = 0; i < posts!.length; i++) {
        int totalreact = posts![i].likes.length +
            posts![i].love!.length +
            posts![i].happy!.length +
            posts![i].please!.length +
            posts![i].sad!.length +
            posts![i].wow!.length;
        setState(() {
          viewReactions.add(false);
          totalreactions.add(totalreact);
        });
        if (posts![i].likes.contains(
            int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
          setState(() {
            postIds.add(posts![i].id);
            currentReaction.add(Reaction.like);
          });
        } else if (posts![i].love!.contains(
            int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
          setState(() {
            postIds.add(posts![i].id);
            currentReaction.add(Reaction.love);
          });
        } else if (posts![i].happy!.contains(
            int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
          setState(() {
            postIds.add(posts![i].id);
            currentReaction.add(Reaction.happy);
          });
        } else if (posts![i].please!.contains(
            int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
          setState(() {
            postIds.add(posts![i].id);
            currentReaction.add(Reaction.please);
          });
        } else if (posts![i].sad!.contains(
            int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
          setState(() {
            postIds.add(posts![i].id);
            currentReaction.add(Reaction.sad);
          });
        } else if (posts![i].wow!.contains(
            int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
          setState(() {
            postIds.add(posts![i].id);
            currentReaction.add(Reaction.wow);
          });
        } else {
          setState(() {
            postIds.add(posts![i].id);
            currentReaction.add(Reaction.none);
          });
        }
      }
      debugPrint("current reaction ${currentReaction.toString()}");
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    }
  }

  Future react(String postId, String userId, String reactionType,
      String pastReaction, int index) async {
    try {
      bool sameReaction = false;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('emotional_stories')
          .doc(postId)
          .get();
      if (reactionType == pastReaction) {
        sameReaction = true;
        List<dynamic> dynlist = doc[reactionType];
        List<int> list = dynlist.cast<int>();
        if (list.contains(int.parse(userId))) {
          list.remove(int.parse(userId));
        }
        await FirebaseFirestore.instance
            .collection('emotional_stories')
            .doc(postId)
            .update({reactionType: list});
        if (reactionType == 'likes') {
          setState(() {
            posts![index].likes = list;
          });
        } else if (reactionType == 'love') {
          setState(() {
            posts![index].love = list;
          });
        } else if (reactionType == 'happy') {
          setState(() {
            posts![index].happy = list;
          });
        } else if (reactionType == 'please') {
          setState(() {
            posts![index].please = list;
          });
        } else if (reactionType == 'sad') {
          setState(() {
            posts![index].sad = list;
          });
        } else if (reactionType == 'wow') {
          setState(() {
            posts![index].wow = list;
          });
        }
      } else {
        List<dynamic> dynlist = doc[reactionType];
        List<int> list = dynlist.cast<int>();
        if (!list.contains(int.parse(userId))) {
          list.add(int.parse(userId));
        }
        await FirebaseFirestore.instance
            .collection('emotional_stories')
            .doc(postId)
            .update({reactionType: list});
        if (reactionType == 'likes') {
          setState(() {
            posts![index].likes = list;
          });
        } else if (reactionType == 'love') {
          setState(() {
            posts![index].love = list;
          });
        } else if (reactionType == 'happy') {
          setState(() {
            posts![index].happy = list;
          });
        } else if (reactionType == 'please') {
          setState(() {
            posts![index].please = list;
          });
        } else if (reactionType == 'sad') {
          setState(() {
            posts![index].sad = list;
          });
        } else if (reactionType == 'wow') {
          setState(() {
            posts![index].wow = list;
          });
        }
        if (pastReaction != 'none') {
          List<dynamic> dynlist = doc[pastReaction];
          List<int> reactlist = dynlist.cast<int>();
          if (reactlist.contains(int.parse(userId))) {
            reactlist.remove(int.parse(userId));
          }
          await FirebaseFirestore.instance
              .collection('emotional_stories')
              .doc(postId)
              .update({pastReaction: reactlist});
          if (pastReaction == 'likes') {
            setState(() {
              posts![index].likes = reactlist;
            });
          } else if (pastReaction == 'love') {
            setState(() {
              posts![index].love = reactlist;
            });
          } else if (pastReaction == 'happy') {
            setState(() {
              posts![index].happy = reactlist;
            });
          } else if (pastReaction == 'please') {
            setState(() {
              posts![index].please = reactlist;
            });
          } else if (pastReaction == 'sad') {
            setState(() {
              posts![index].sad = reactlist;
            });
          } else if (pastReaction == 'wow') {
            setState(() {
              posts![index].wow = reactlist;
            });
          }
        }
      }

      for (int i = 0; i < postIds.length; i++) {
        if (postId == postIds[i]) {
          setState(() {
            sameReaction
                ? currentReaction[i] = getReaction("none")
                : currentReaction[i] = getReaction(reactionType);
          });
        }
      }

      setState(() {
        totalreactions[index] = posts![index].likes.length +
            posts![index].love!.length +
            posts![index].happy!.length +
            posts![index].please!.length +
            posts![index].sad!.length +
            posts![index].wow!.length;
      });
    } catch (e) {
      debugPrint("react $e");
    }
  }

  String getReactionName(Reaction reaction) {
    if (reaction == Reaction.like) {
      return "likes";
    } else if (reaction == Reaction.love) {
      return "love";
    } else if (reaction == Reaction.happy) {
      return "happy";
    } else if (reaction == Reaction.please) {
      return "please";
    } else if (reaction == Reaction.sad) {
      return "sad";
    } else if (reaction == Reaction.wow) {
      return "wow";
    }
    return "none";
  }

  Reaction getReaction(String name) {
    if (name == "likes") {
      return Reaction.like;
    } else if (name == "love") {
      return Reaction.love;
    } else if (name == "happy") {
      return Reaction.happy;
    } else if (name == "please") {
      return Reaction.please;
    } else if (name == "sad") {
      return Reaction.sad;
    } else if (name == "wow") {
      return Reaction.wow;
    }
    return Reaction.none;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: detailScreenBgColor,
      appBar: SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
          ? AppBar(
              elevation: 0,
              backgroundColor:
                  SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
                      ? colorBlue
                      : colorWhite,
              iconTheme: const IconThemeData(color: colorWhite),
              shape:
                  SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
                      ? const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        )
                      : null,
              title:
                  SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
                      ? Text(
                          'Emotional Story'.tr,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: colorWhite,
                          ),
                        )
                      : null,
              automaticallyImplyLeading: false,
            )
          : null,
      body: posts!.isNotEmpty
          ? Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          )
                        : BorderRadius.zero,
                gradient:
                    SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
                        ? LinearGradient(
                            colors: [
                              ui_mode == "dark"
                                  ? colorBlack
                                  : const Color(0xffF5FAFF),
                              const Color(0xff128AF8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : LinearGradient(
                            colors: [
                              ui_mode == "dark"
                                  ? detailScreenCardColor
                                  : colorWhite,
                              ui_mode == "dark"
                                  ? detailScreenCardColor
                                  : colorWhite,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: posts!.length,
                  itemBuilder: (context, storyIndex) {
                    return Column(
                      children: [
                        Card(
                          color: colorWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: ui_mode == "dark"
                                      ? colorGrey
                                      : colorBlack),
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  ui_mode == "dark"
                                      ? colorBlack
                                      : const Color(0xffF5FAFF),
                                  const Color(0xff128AF8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      posts![storyIndex].profilePic != ""
                                          ? showImage(
                                              0.0,
                                              NetworkImage(posts![storyIndex]
                                                  .profilePic),
                                            )
                                          : showIcon(
                                              25,
                                              ui_mode == "dark"
                                                  ? colorWhite
                                                  : colorBlack,
                                              Icons.person,
                                              20,
                                              colorGrey),
                                      const SizedBox(width: 10),
                                      Text(
                                        posts![storyIndex].name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: ui_mode == "dark"
                                              ? colorWhite
                                              : colorBlack,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      posts![storyIndex].status == 'verified'
                                          ? Image.asset(
                                              'assets/verified.png',
                                              width: 40,
                                              height: 40,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.blueGrey,
                                    thickness: 1,
                                    endIndent: 10,
                                    indent: 10,
                                  ),
                                  Text(
                                    posts![storyIndex].content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                      color: ui_mode == "dark"
                                          ? colorWhite
                                          : Colors.black54,
                                    ),
                                  ),
                                  Divider(
                                    color: ui_mode == "dark"
                                        ? colorBlack
                                        : Colors.blueGrey,
                                    thickness: 1,
                                    endIndent: 10,
                                    indent: 10,
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_selectedPostIndex == storyIndex)
                                            Container(
                                              height: 40,
                                              width: 240,
                                              decoration: BoxDecoration(
                                                color: ui_mode == "dark"
                                                    ? cardColor
                                                    : Colors.white60,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: AnimationLimiter(
                                                child: ListView.builder(
                                                  itemCount: reactions.length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return AnimationConfiguration
                                                        .staggeredList(
                                                      position: index,
                                                      duration: const Duration(
                                                        milliseconds: 375,
                                                      ),
                                                      child: SlideAnimation(
                                                        verticalOffset:
                                                            15 + index * 15,
                                                        child: FadeInAnimation(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: InkWell(
                                                              onTap: () =>
                                                                  setState(() {
                                                                posts![storyIndex]
                                                                        .reaction =
                                                                    reactions[
                                                                            index]
                                                                        .reaction;
                                                              }),
                                                              child: reactions[
                                                                      index]
                                                                  .image,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          if (viewReactions[storyIndex]) ...{
                                            posts != null &&
                                                    posts!.length > storyIndex
                                                ? Container(
                                                    width: width * 0.65,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: cardColor,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        //! likes
                                                        GestureDetector(
                                                          onTap: () async {
                                                            await react(
                                                                posts![storyIndex]
                                                                    .id,
                                                                SharedPreference
                                                                    .getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID),
                                                                'likes',
                                                                getReactionName(
                                                                    currentReaction[
                                                                        storyIndex]),
                                                                storyIndex);
                                                            setState(() {
                                                              viewReactions[
                                                                      storyIndex] =
                                                                  false;
                                                            });
                                                          },
                                                          child: Column(
                                                            children: [
                                                              getReactionIcon(
                                                                  Reaction
                                                                      .like),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.01),
                                                              Text(
                                                                posts![storyIndex]
                                                                        .likes
                                                                        .isNotEmpty
                                                                    ? posts![
                                                                            storyIndex]
                                                                        .likes
                                                                        .length
                                                                        .toString()
                                                                    : '',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: ui_mode ==
                                                                          "dark"
                                                                      ? colorWhite
                                                                      : colorBlack,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        //! love
                                                        GestureDetector(
                                                          onTap: () async {
                                                            await react(
                                                                posts![storyIndex]
                                                                    .id,
                                                                SharedPreference
                                                                    .getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID),
                                                                'love',
                                                                getReactionName(
                                                                    currentReaction[
                                                                        storyIndex]),
                                                                storyIndex);
                                                            setState(() {
                                                              viewReactions[
                                                                      storyIndex] =
                                                                  false;
                                                            });
                                                          },
                                                          child: Column(
                                                            children: [
                                                              getReactionIcon(
                                                                  Reaction
                                                                      .love),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.01),
                                                              Text(
                                                                posts![storyIndex]
                                                                        .love!
                                                                        .isEmpty
                                                                    ? ' '
                                                                    : posts![
                                                                            storyIndex]
                                                                        .love!
                                                                        .length
                                                                        .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: ui_mode ==
                                                                          "dark"
                                                                      ? colorWhite
                                                                      : colorBlack,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        //! Happy
                                                        GestureDetector(
                                                          onTap: () async {
                                                            await react(
                                                                posts![storyIndex]
                                                                    .id,
                                                                SharedPreference
                                                                    .getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID),
                                                                'happy',
                                                                getReactionName(
                                                                    currentReaction[
                                                                        storyIndex]),
                                                                storyIndex);
                                                            setState(() {
                                                              viewReactions[
                                                                      storyIndex] =
                                                                  false;
                                                            });
                                                          },
                                                          child: Column(
                                                            children: [
                                                              getReactionIcon(
                                                                  Reaction
                                                                      .happy),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.01),
                                                              Text(
                                                                posts![storyIndex]
                                                                        .happy!
                                                                        .isEmpty
                                                                    ? ' '
                                                                    : posts![
                                                                            storyIndex]
                                                                        .happy!
                                                                        .length
                                                                        .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: ui_mode ==
                                                                          "dark"
                                                                      ? colorWhite
                                                                      : colorBlack,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        //! Wow
                                                        GestureDetector(
                                                          onTap: () async {
                                                            await react(
                                                                posts![storyIndex]
                                                                    .id,
                                                                SharedPreference
                                                                    .getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID),
                                                                'wow',
                                                                getReactionName(
                                                                    currentReaction[
                                                                        storyIndex]),
                                                                storyIndex);
                                                            setState(() {
                                                              viewReactions[
                                                                      storyIndex] =
                                                                  false;
                                                            });
                                                          },
                                                          child: Column(
                                                            children: [
                                                              getReactionIcon(
                                                                  Reaction.wow),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.01),
                                                              Text(
                                                                posts![storyIndex]
                                                                        .wow!
                                                                        .isEmpty
                                                                    ? ' '
                                                                    : posts![
                                                                            storyIndex]
                                                                        .wow!
                                                                        .length
                                                                        .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: ui_mode ==
                                                                          "dark"
                                                                      ? colorWhite
                                                                      : colorBlack,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        //! Sad
                                                        GestureDetector(
                                                          onTap: () async {
                                                            await react(
                                                                posts![storyIndex]
                                                                    .id,
                                                                SharedPreference
                                                                    .getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID),
                                                                'sad',
                                                                getReactionName(
                                                                    currentReaction[
                                                                        storyIndex]),
                                                                storyIndex);
                                                            setState(() {
                                                              viewReactions[
                                                                      storyIndex] =
                                                                  false;
                                                            });
                                                          },
                                                          child: Column(
                                                            children: [
                                                              getReactionIcon(
                                                                  Reaction.sad),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.01),
                                                              Text(
                                                                posts![storyIndex]
                                                                        .sad!
                                                                        .isEmpty
                                                                    ? ' '
                                                                    : posts![
                                                                            storyIndex]
                                                                        .sad!
                                                                        .length
                                                                        .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: ui_mode ==
                                                                          "dark"
                                                                      ? colorWhite
                                                                      : colorBlack,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        //! Please
                                                        GestureDetector(
                                                          onTap: () async {
                                                            await react(
                                                                posts![storyIndex]
                                                                    .id,
                                                                SharedPreference
                                                                    .getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID),
                                                                'please',
                                                                getReactionName(
                                                                    currentReaction[
                                                                        storyIndex]),
                                                                storyIndex);
                                                            setState(() {
                                                              viewReactions[
                                                                      storyIndex] =
                                                                  false;
                                                            });
                                                          },
                                                          child: Column(
                                                            children: [
                                                              getReactionIcon(
                                                                  Reaction
                                                                      .please),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.01),
                                                              Text(
                                                                posts![storyIndex]
                                                                        .please!
                                                                        .isEmpty
                                                                    ? ' '
                                                                    : posts![
                                                                            storyIndex]
                                                                        .please!
                                                                        .length
                                                                        .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: ui_mode ==
                                                                          "dark"
                                                                      ? colorWhite
                                                                      : colorBlack,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                          },
                                          InkWell(
                                              onTap: () {
                                                setState(() {
                                                  viewReactions[storyIndex] =
                                                      !viewReactions[
                                                          storyIndex];
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  getReactionIcon(
                                                      currentReaction[
                                                          storyIndex]),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    totalreactions[storyIndex]
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: ui_mode == "dark"
                                                          ? colorWhite
                                                          : colorBlack,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () => _showCommentSheet(
                                          context,
                                          posts![storyIndex].id,
                                          posts![storyIndex],
                                        ),
                                        child: const Icon(
                                          Icons.comment,
                                          color: Colors.white54,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                              '${posts![storyIndex].comments.length}',
                                              style: TextStyle(
                                                color: ui_mode == "dark"
                                                    ? colorWhite
                                                    : colorBlack,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  },
                ),
              ),
            )
          : _noPostsFound(),
    );
  }

  void _showCommentSheet(BuildContext context, String postId, UserPost? post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        double screenHeight = MediaQuery.of(context).size.height;
        double sheetHeight = screenHeight * 0.8;

        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: sheetHeight,
          child: CommentScreen(postId: postId, post: post!),
        );
      },
    ).whenComplete(() {
      _fetchPosts();
    });
  }

  final List<ReactionElement> reactions = [
    ReactionElement(
      Reaction.like,
      showIcon(0.0, colorBlue, Icons.thumb_up_rounded, 10, Colors.transparent),
    ),
    ReactionElement(
      Reaction.love,
      showImage(12, const AssetImage('assets/emoji/love.png')),
    ),
    ReactionElement(
      Reaction.happy,
      showImage(12, const AssetImage('assets/emoji/happy.png')),
    ),
    ReactionElement(
      Reaction.wow,
      showImage(12, const AssetImage('assets/emoji/wow.png')),
    ),
    ReactionElement(
      Reaction.sad,
      showImage(12, const AssetImage('assets/emoji/sad.png')),
    ),
    ReactionElement(
      Reaction.please,
      showImage(12, const AssetImage('assets/emoji/please.png')),
    ),
  ];

  Image getReactionIcon(Reaction reaction) {
    switch (reaction) {
      case Reaction.like:
        return const Image(
          height: 23,
          image: AssetImage('assets/emoji/done.png'),
          fit: BoxFit.cover,
        );
      case Reaction.love:
        return const Image(
          height: 23,
          image: AssetImage('assets/emoji/love.png'),
          fit: BoxFit.cover,
        );
      case Reaction.happy:
        return const Image(
          height: 23,
          image: AssetImage('assets/emoji/happy.png'),
          fit: BoxFit.cover,
        );
      case Reaction.wow:
        return const Image(
          height: 23,
          image: AssetImage('assets/emoji/wow.png'),
          fit: BoxFit.cover,
        );
      case Reaction.sad:
        return const Image(
          height: 23,
          image: AssetImage('assets/emoji/sad.png'),
          fit: BoxFit.cover,
        );
      case Reaction.please:
        return const Image(
          height: 23,
          image: AssetImage('assets/emoji/please.png'),
          fit: BoxFit.cover,
        );
      case Reaction.none:
        return const Image(
          height: 23,
          image: AssetImage('assets/emoji/none.png'),
          fit: BoxFit.cover,
        );
      default:
        return const Image(
          height: 23,
          image: AssetImage('assets/emoji/none.png'),
          color: colorBlack,
          fit: BoxFit.cover,
        );
    }
  }

  Widget _noPostsFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "No Stories Found".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ui_mode == "dark" ? colorWhite : colorBlack),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
