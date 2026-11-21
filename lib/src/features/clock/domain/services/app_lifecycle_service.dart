/// Domain service contract for exiting or backgrounding the application.
abstract interface class AppLifecycleService {
  Future<void> exitApp();
}
