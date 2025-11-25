import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/counter_controller.dart';
import '../widgets/welcome_dialog.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  late CounterController controller;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CounterController());
    _setupWelcomeDialogListener();
  }

  void _setupWelcomeDialogListener() {
    // Watch isLoading to know when initialization is complete
    controller.isLoading.listen((isLoading) {
      if (!isLoading && !_dialogShown && controller.isFirstLaunch.value) {
        _showWelcomeDialog();
      }
    });
  }

  void _showWelcomeDialog() {
    _dialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentContext = context;
        showDialog(
          context: currentContext,
          barrierDismissible: false,
          builder: (dialogContext) => WelcomeDialog(
            onDismiss: () async {
              await controller.dismissWelcomeDialog();
              if (mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter App'),
        centerTitle: true,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xff1a1a2e),
                      const Color(0xff16213e),
                    ],
                  ),
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade300,
                        Colors.cyan.shade400,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      key: const Key('counter_text'),
                      '${controller.counter.value}',
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.incrementCounter(),
          tooltip: 'Increment',
          backgroundColor: Colors.blue.shade400,
          shape: const CircleBorder(),
          elevation: 8,
          child: const Icon(
            Icons.add,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
