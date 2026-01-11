class Session {
  static String? cookie; 
  static String? role;   
  static String? email;

  static void clear() {
    cookie = null;
    role = null;
    email = null;
  }
}
