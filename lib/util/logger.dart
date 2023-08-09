import 'package:logger/logger.dart' as logLib;

class Logger {
  static final logLib.Logger logger = logLib.Logger(
    level: logLib.Level.verbose, // Adjust the log level as needed
    printer: logLib.PrettyPrinter(), // Use PrettyPrinter for formatted output
  );

  static void error(String message) {
    logger.e(message);
  }

  static void info(String message) {
    logger.i(message);
  }

  static void debug(String message) {
    logger.d(message);
  }

  static void warning(String message) {
    logger.w(message);
  }
}
