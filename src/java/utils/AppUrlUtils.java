package utils;

import jakarta.servlet.http.HttpServletRequest;

public final class AppUrlUtils {
    private AppUrlUtils() {}

    public static String resolveBaseUrl(HttpServletRequest request) {
        String configured = MailSettings.getBaseUrl();
        if (configured != null && !configured.trim().isEmpty()) {
            return configured.trim().replaceAll("/$", "");
        }
        StringBuilder sb = new StringBuilder();
        sb.append(request.getScheme()).append("://").append(request.getServerName());
        if (!(("http".equalsIgnoreCase(request.getScheme()) && request.getServerPort() == 80)
                || ("https".equalsIgnoreCase(request.getScheme()) && request.getServerPort() == 443))) {
            sb.append(":").append(request.getServerPort());
        }
        sb.append(request.getContextPath());
        return sb.toString();
    }
}
