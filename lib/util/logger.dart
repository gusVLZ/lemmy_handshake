import 'package:logger/logger.dart' as log_lib;

class Logger {
  static final log_lib.Logger logger = log_lib.Logger(
    level: log_lib.Level.verbose, // Adjust the log level as needed
    printer: log_lib.PrettyPrinter(), // Use PrettyPrinter for formatted output
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
