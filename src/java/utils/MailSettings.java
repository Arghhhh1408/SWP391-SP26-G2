package utils;

public final class MailSettings {

    private MailSettings() {
    }

    private static String read(String key, String def) {
        String v = System.getProperty(key);
        if (v == null || v.trim().isEmpty()) {
            v = System.getenv(key);
        }
        return (v == null || v.trim().isEmpty()) ? def : v.trim();
    }

    public static String getHost() {
        return read("MAIL_SMTP_HOST", "localhost");
    }

    public static int getPort() {
        try {
            return Integer.parseInt(read("MAIL_SMTP_PORT", "1025"));
        } catch (Exception e) {
            return 1025;
        }
    }

    public static String getFromEmail() {
        return read("MAIL_FROM_EMAIL", "no-reply@local.test");
    }

    public static String getFromName() {
        return read("MAIL_FROM_NAME", "SIM Inventory");
    }

    public static String getFromAddress() {
        return getFromName() + " <" + getFromEmail() + ">";
    }

    public static String getBaseUrl() {
        return read("APP_BASE_URL", "http://localhost:9999/SIM");
    }
}
