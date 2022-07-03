import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:whisperp/models/chat_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:io';

import '../../../constants.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({super.key, required this.messagesDocId});

  final String messagesDocId;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation degOneTranslationAnimation,degTwoTranslationAnimation,degThreeTranslationAnimation;
  late Animation rotationAnimation;
  late List<XFile> _imageFileList;
  final recorder = FlutterSoundRecorder();
  var path = "";
  bool isRecorderReady = false;

  void _setImageFileListFromFile(XFile value) {
    _imageFileList = (value == null ? null : <XFile>[value])!;
  }

  dynamic _pickImageError;
  bool isVideo = false;

   VideoPlayerController? _controller;
  late VideoPlayerController _toBeDisposed;
  late String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();


  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian; 
  }
  Future<void> _playVideo(XFile file) async {
    if (mounted) {
      await _disposeVideoController();
       VideoPlayerController controller;
      if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {
        controller = VideoPlayerController.file(File(file.path));
      }
      _controller = controller;
      // In web, most browsers won't honor a programmatic call to .play
      // if the video has a sound track (and is not muted).
      // Mute the video so it auto-plays in web!
      // This is not needed if the call to .play is the result of user
      // interaction (clicking on a "play" button, for example).
      const double volume = kIsWeb ? 0.0 : 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      { BuildContext? context, bool isMultiImage = false}) async {
    if (_controller != null) {
      await _controller?.setVolume(0.0);
    }
    if (isVideo) {
      final XFile? file = await _picker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      await _playVideo(file!);
    } else if (isMultiImage) {

        try {
          final List<XFile>? pickedFileList = await _picker.pickMultiImage(
            
          );
          setState(() {
            _imageFileList = pickedFileList!;
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      
    } else {

        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: source,);
            
          
          setState(() {
            _setImageFileListFromFile(pickedFile!);
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller?.setVolume(0.0);
      _controller?.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    animationController.dispose();
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed.dispose();
    }
    _toBeDisposed = _controller!;
    _controller = null;
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if(status !=PermissionStatus.granted)
    {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    isRecorderReady = true;
  }

  Widget _previewVideo() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller!),
    );
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            // Why network for web?
            // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: kIsWeb
                  ? Image.network(_imageFileList[index].path)
                  : Image.file(File(_imageFileList[index].path)),
            );
          },
          itemCount: _imageFileList.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _handlePreview() {
    if (isVideo) {
      return _previewVideo();
    } else {
      return _previewImages();
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file!);
      } else {
        isVideo = false;
        setState(() {
          if (response.files == null) {
            _setImageFileListFromFile(response.file!);
          } else {
            _imageFileList = response.files!;
          }
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  void initState() {
    VideoPlayerController? _controller;

    animationController = AnimationController(vsync: this,duration: const Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.2,end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.4,end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.75,end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0,end: 0.0).animate(CurvedAnimation(parent: animationController
        , curve: Curves.easeOut));
    initRecorder();
    super.initState();
    animationController.addListener((){
      setState(() {

      });
    });
  }
  
  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return ;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future _localFile() async {
    path = await _localPath;
    
  }

    Future record() async{
      if(!isRecorderReady) return;
      await recorder.startRecorder(toFile: 'audio');

    }

    Future stop() async{
      if(!isRecorderReady) return;
      await recorder.stopRecorder();
      await _localFile();
      final audioFile = File(path);

    }

  @override
  Widget build(BuildContext context) {
    final textEditCtrlr = TextEditingController(text: "");
    Size size = MediaQuery.of(context).size;
     

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            CircularButton(
              color: Colors.blue,
              width: 50,
              height: 50,
              icon: !recorder.isRecording ?  Icon(Icons.mic, color: Colors.white) : 
                                              Icon(Icons.stop, color: Colors.white),
              onClick: () async {
              if(recorder.isRecording)
              {
                await stop();
              }else{
                await record();
              }
              setState(() {
                
              });
            }),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding * 0.75,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Stack(
                  children: [ Row(children: [
                    Expanded(
                      child: TextField(
                        controller: textEditCtrlr,
                        decoration: const InputDecoration(
                          hintText: "Type message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    Positioned(
                          right: 30,
                          bottom: 30,
                          child: Stack(
                              alignment: Alignment.bottomRight,
                              children: <Widget>[
                              IgnorePointer(
                                  child: Container(
                                  color: Colors.transparent,
                                  height: 150.0,
                                  width: 150.0,
                                  ),
                              ),
                              Transform.translate(
                                  offset: Offset.fromDirection(getRadiansFromDegree(270),degOneTranslationAnimation.value * 100),
                                  child: Transform(
                                  transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))..scale(degOneTranslationAnimation.value),
                                  alignment: Alignment.center,
                                  child: CircularButton(
                                      color: Colors.blue,
                                      width: 50,
                                      height: 50,
                                      icon: const Icon(
                                        Icons.video_camera_back_outlined,
                                        color: Colors.white,
                                        ),
                                        onClick: (){
                                          isVideo = true;
                                          _onImageButtonPressed(ImageSource.camera);
                                            print('First Button');
                                        },
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                    offset: Offset.fromDirection(getRadiansFromDegree(225),degTwoTranslationAnimation.value * 100),
                                    child: Transform(
                                      transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))..scale(degTwoTranslationAnimation.value),
                                      alignment: Alignment.center,
                                      child: CircularButton(
                                        color: Colors.black,
                                        width: 50,
                                        height: 50,
                                        icon: const Icon(
                                        Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                        onClick: (){
                                          isVideo = false;
                                          _onImageButtonPressed(ImageSource.camera, context: context);
                                          print('Second button');
                                        },
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: Offset.fromDirection(getRadiansFromDegree(180),degThreeTranslationAnimation.value * 100),
                                     child: Transform(
                                        transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))..scale(degThreeTranslationAnimation.value),
                                        alignment: Alignment.center,
                                        child: CircularButton(
                                            color: Colors.orangeAccent,
                                            width: 50,
                                            height: 50,
                                            icon: const Icon(
                                                Icons.photo_library,
                                                color: Colors.white,
                                            ),
                                            onClick: (){
                                              isVideo = false;
                                             _onImageButtonPressed(ImageSource.gallery, context: context);
                                              print('Third Button');
                                            },
                                          ),
                                        ),
                                    ),
                                    Transform(
                                        transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value)),
                                        alignment: Alignment.center,
                                        child: CircularButton(
                                            color: Colors.blue,
                                            width: 60,
                                            height: 60,
                                            icon: const Icon(
                                              Icons.attach_file,
                                              color: Colors.white,
                                            ),
                                          onClick: (){
                                            if (animationController.isCompleted) {
                                              animationController.reverse();
                                            } else {
                                              animationController.forward();
                                            }
                                            },
                                          ),
                                        )

                            ],
                          ),
                        )
                      ],
                    ),
                    
                    
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                if (textEditCtrlr.text.isNotEmpty) {
                  final message = ChatMessage(
                    text: textEditCtrlr.text,
                    senderId: FirebaseAuth.instance.currentUser!.uid,
                    messageType: ChatMessageType.text,
                    messageStatus: MessageStatus.notview,
                    timestamp: DateTime.now(),
                  );

                  textEditCtrlr.text = "";

                  FirebaseFirestore.instance
                      .collection('messages')
                      .doc(messagesDocId)
                      .collection('messages')
                      .add({
                    ...message.toMap(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularButton extends StatelessWidget {

  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final void Function() onClick;

  CircularButton({required this.color, required this.width, required this.height,required this.icon,required this.onClick});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color,shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(icon: icon,enableFeedback: true, onPressed: onClick),
    );
  }
}


typedef OnPickImageCallback = void Function(
    double maxWidth, double maxHeight, int quality);

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, {Key? key}) : super(key: key);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.isInitialized) {
      initialized = controller.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);

  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
