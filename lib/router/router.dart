import 'package:go_router/go_router.dart';
import 'package:walkly/features/editor_preview/view/editor_view.dart';
import 'package:walkly/router/app_page.dart';

class AppRoute {
  static final router = GoRouter(
    initialLocation: AppPages.home,
    routes: [
      GoRoute(
        path: AppPages.home,
        builder: (context, state) => const EditorView(),
      ),
    ],
  );
}
