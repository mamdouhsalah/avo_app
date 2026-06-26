import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioBubble extends StatefulWidget {
  final String audioUrl;
  final bool isUser;

  const AudioBubble({super.key, required this.audioUrl, required this.isUser});

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setSourceUrl(widget.audioUrl);
      
      _audioPlayer.onDurationChanged.listen((d) {
        if (mounted) setState(() { _duration = d; _isLoading = false; });
      });

      _audioPlayer.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        }
      });
      
      // Fallback if duration takes too long
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isLoading) setState(() => _isLoading = false);
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isUser ? Colors.white : theme.colorScheme.primary;

    return Container(
      width: 200.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          _isLoading
              ? SizedBox(
                  width: 32.w,
                  height: 32.w,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: CircularProgressIndicator(
                      color: color,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: color,
                    size: 32.sp,
                  ),
                  onPressed: () async {
                    if (_isPlaying) {
                      await _audioPlayer.pause();
                      setState(() => _isPlaying = false);
                    } else {
                      await _audioPlayer.play(UrlSource(widget.audioUrl));
                      setState(() => _isPlaying = true);
                    }
                  },
                ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
                trackHeight: 2.h,
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.3),
                thumbColor: color,
              ),
              child: Slider(
                min: 0,
                max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 100,
                value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
                onChanged: (value) async {
                  await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ),
          Text(
            _formatDuration(_isPlaying ? _position : _duration),
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
