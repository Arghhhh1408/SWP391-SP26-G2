package utils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import simmail.LocalSmtpMailApi;

public final class AsyncMailDispatcher {
    private static final ExecutorService EXECUTOR = Executors.newFixedThreadPool(2);

    private AsyncMailDispatcher() {}

    public static void sendHtmlAsync(String to, String subject, String html) {
        if (to == null || to.trim().isEmpty()) return;
        EXECUTOR.submit(() -> {
            try {
                LocalSmtpMailApi.sendHtml(MailSettings.getHost(), MailSettings.getPort(), MailSettings.getFromAddress(), to.trim(), subject, html);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    public static void sendHtmlAsync(Collection<String> recipients, String subject, String html) {
        if (recipients == null || recipients.isEmpty()) return;
        List<String> clean = new ArrayList<>();
        for (String recipient : recipients) {
            if (recipient != null && !recipient.trim().isEmpty()) clean.add(recipient.trim());
        }
        if (clean.isEmpty()) return;
        EXECUTOR.submit(() -> {
            try {
                LocalSmtpMailApi.sendHtml(MailSettings.getHost(), MailSettings.getPort(), MailSettings.getFromAddress(), clean, subject, html);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }
}
