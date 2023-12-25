import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

class TabScreenProfile extends StatefulWidget {
  const TabScreenProfile({Key? key}) : super(key: key);

  @override
  State<TabScreenProfile> createState() => _TabScreenProfileState();
}

class _TabScreenProfileState extends State<TabScreenProfile> {
  late double _distanceToField;
  late TextfieldTagsController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextfieldTagsController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: Center(
          child: TextFieldTags(
            textfieldTagsController: _controller,
            initialTags: const ['Bargeld', 'DKB Giro', 'DKB Tagesgeld', 'VR Giro'],
            textSeparators: const [' ', ','],
            letterCase: LetterCase.normal,
            inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
              return ((context, sc, tags, onTagDelete) {
                return TextField(
                  controller: tec,
                  focusNode: fn,
                  decoration: InputDecoration(
                    isDense: true,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 3.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 3.0),
                    ),
                    hintText: _controller.hasTags ? '' : 'Enter tag...',
                    errorText: error,
                    prefixIconConstraints:
                        BoxConstraints(maxWidth: _distanceToField * 0.74),
                    prefixIcon: SingleChildScrollView(
                            controller: sc,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: tags.map((String tag) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        child: Text('$tag'),
                                        onTap: () {
                                          print('$tag selected');
                                        },
                                      ),
                                      const SizedBox(width: 4.0),
                                      InkWell(
                                        child: const Icon(
                                          Icons.cancel_outlined,
                                          size: 20.0,
                                        ),
                                        onTap: () {
                                          onTagDelete(tag);
                                        },
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                );
              });
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('${_controller.getTags}');
        },
        child: Icon(Icons.print),
      ),
    );
  }
}
