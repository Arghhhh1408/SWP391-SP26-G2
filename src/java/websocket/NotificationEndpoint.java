package websocket;

import dao.NotificationDAO;
import jakarta.servlet.http.HttpSession;
import jakarta.websocket.EndpointConfig;
import jakarta.websocket.HandshakeResponse;
import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.HandshakeRequest;
import jakarta.websocket.server.ServerEndpoint;
import jakarta.websocket.server.ServerEndpointConfig;
import model.User;
import java.io.IOException;
import java.util.Collections;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint(value = "/notifications", configurator = NotificationEndpoint.Configurator.class)
public class NotificationEndpoint {

    // userId -> set of open WebSocket sessions
    private static final Map<Integer, Set<Session>> userSessions = new ConcurrentHashMap<>();

    // -----------------------------------------------------------------------
    // Configurator: copies HttpSession into WebSocket user properties
    // -----------------------------------------------------------------------
    public static class Configurator extends ServerEndpointConfig.Configurator {
        @Override
        public void modifyHandshake(ServerEndpointConfig config,
                                    HandshakeRequest request,
                                    HandshakeResponse response) {
            HttpSession httpSession = (HttpSession) request.getHttpSession();
            if (httpSession != null) {
                config.getUserProperties().put(HttpSession.class.getName(), httpSession);
            }
        }
    }

    // -----------------------------------------------------------------------
    // Lifecycle
    // -----------------------------------------------------------------------
    @OnOpen
    public void onOpen(Session wsSession, EndpointConfig config) {
        HttpSession httpSession = (HttpSession) config.getUserProperties()
                .get(HttpSession.class.getName());
        if (httpSession == null) { silentClose(wsSession); return; }

        User user = (User) httpSession.getAttribute("acc");
        if (user == null) { silentClose(wsSession); return; }

        int userId = user.getUserID();
        wsSession.getUserProperties().put("userId", userId);

        userSessions.computeIfAbsent(userId, k -> Collections.newSetFromMap(new ConcurrentHashMap<>()))
                    .add(wsSession);

        // Send initial unread count
        try {
            int unread = new NotificationDAO().countUnread(userId);
            wsSession.getBasicRemote().sendText("{\"unreadCount\":" + unread + "}");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @OnClose
    public void onClose(Session wsSession) {
        removeSession(wsSession);
    }

    @OnError
    public void onError(Session wsSession, Throwable t) {
        removeSession(wsSession);
    }

    // -----------------------------------------------------------------------
    // Static helpers used by controllers
    // -----------------------------------------------------------------------

    /** Push a JSON message to all sessions of a specific user */
    public static void sendToUser(int userId, String json) {
        Set<Session> sessions = userSessions.get(userId);
        if (sessions == null) return;
        for (Session s : sessions) {
            if (s.isOpen()) {
                try { s.getBasicRemote().sendText(json); }
                catch (IOException e) { e.printStackTrace(); }
            }
        }
    }

    /** Push a message to ALL online managers (RoleID=2).
     *  managerIds must be passed in to avoid DB call inside the static context. */
    public static void sendToManagers(java.util.List<Integer> managerIds, String json) {
        for (int mid : managerIds) {
            sendToUser(mid, json);
        }
    }

    // -----------------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------------
    private void removeSession(Session wsSession) {
        Object uid = wsSession.getUserProperties().get("userId");
        if (uid instanceof Integer) {
            Set<Session> sessions = userSessions.get(uid);
            if (sessions != null) sessions.remove(wsSession);
        }
    }

    private void silentClose(Session s) {
        try { s.close(); } catch (IOException ignored) {}
    }
}
