import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_animations.dart';

/// Voice Bubble Component - Exact replica of React Native implementation
/// Displays animated microphone icon with 5-bar sound visualization
class VoiceBubble extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isActive;
  final String label;

  const VoiceBubble({
    super.key,
    this.onPressed,
    this.isActive = false,
    this.label = '',
  });

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _soundbarController;
  late Animation<double> _waveScaleAnimation;
  late Animation<double> _waveOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Wave animation controller
    _waveController = AnimationController(
      vsync: this,
      duration: AppAnimations.voiceWaveDuration,
    );
    
    // Soundbar animation controller
    _soundbarController = AnimationController(
      vsync: this,
      duration: AppAnimations.soundbarLoopDuration,
    );

    // Wave animations
    _waveScaleAnimation = Tween<double>(
      begin: AppAnimations.waveScaleStart,
      end: AppAnimations.waveScaleEnd,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: AppAnimations.voiceBubbleCurve,
    ));

    _waveOpacityAnimation = Tween<double>(
      begin: AppAnimations.waveOpacityStart,
      end: AppAnimations.waveOpacityEnd,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: AppAnimations.voiceBubbleCurve,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    if (widget.isActive) {
      // Start wave animation sequence
      _waveController.repeat();
      
      // Start soundbar loop
      _soundbarController.repeat();
    } else {
      // Subtle idle animation for soundbars
      _soundbarController.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _soundbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice bubble circle
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing wave animation (only when active)
              if (widget.isActive)
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Container(
                      width: AppSpacing.voiceBubbleSize,
                      height: AppSpacing.voiceBubbleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(_waveOpacityAnimation.value),
                          width: 2,
                        ),
                      ),
                      transform: Matrix4.identity()
                        ..scale(_waveScaleAnimation.value),
                    );
                  },
                ),
              
              // Main bubble
              Container(
                width: AppSpacing.voiceBubbleSize,
                height: AppSpacing.voiceBubbleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Microphone icon
                    Icon(
                      Icons.mic,
                      size: AppSpacing.voiceBubbleIconSize,
                      color: AppColors.accentMain,
                    ),
                    const SizedBox(height: 4),
                    
                    // 5-bar sound visualization
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return _SoundBar(
                          index: index,
                          controller: _soundbarController,
                          isActive: widget.isActive,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Label text
          if (widget.label.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              widget.isActive ? 'Tap to stop' : widget.label.isEmpty ? 'Talk with AI' : widget.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual sound bar with unique animation pattern
class _SoundBar extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final bool isActive;

  const _SoundBar({
    required this.index,
    required this.controller,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    late Animation<double> scaleAnimation;
    
    // Each bar has unique animation pattern
    switch (index) {
      case 0:
        scaleAnimation = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.2, end: 0.8)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.8, end: 0.2)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50,
          ),
        ]).animate(controller);
        break;
      case 1:
        scaleAnimation = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.4, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 0.3)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.3, end: 0.4)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
        ]).animate(controller);
        break;
      case 2:
        scaleAnimation = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.3, end: 0.9)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 60,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.9, end: 0.3)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 40,
          ),
        ]).animate(controller);
        break;
      case 3:
        scaleAnimation = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.5, end: 1.1)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.1, end: 0.4)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.4, end: 0.5)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 20,
          ),
        ]).animate(controller);
        break;
      case 4:
        scaleAnimation = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.25, end: 0.7)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 20,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.7, end: 0.6)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.6, end: 0.25)
              .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50,
          ),
        ]).animate(controller);
        break;
      default:
        scaleAnimation = Tween(begin: 0.3, end: 0.5).animate(controller);
    }

    if (!isActive) {
      // Subtle animation when inactive
      scaleAnimation = Tween(begin: 0.3, end: 0.5)
          .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }

    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        final height = scaleAnimation.value * 24.0; // Max height 24px
        return Container(
          width: AppSpacing.soundbarWidth,
          height: height.clamp(4.0, 24.0), // Min 4px, Max 24px
          margin: EdgeInsets.only(
            right: index < 4 ? AppSpacing.soundbarGap : 0,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentMain,
            borderRadius: BorderRadius.circular(AppSpacing.soundbarBorderRadius),
          ),
        );
      },
    );
  }
}

