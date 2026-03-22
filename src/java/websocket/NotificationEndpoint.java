package websocket;

import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

@ServerEndpoint("/ws/notifications/{userId}")
public class NotificationEndpoint {

    // Store sessions by userId
    private static final ConcurrentHashMap<String, Set<Session>> userSessions = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session, @PathParam("userId") String userId) {
        userSessions.computeIfAbsent(userId, k -> Collections.synchronizedSet(new HashSet<>())).add(session);
        System.out.println("WebSocket Connected: User " + userId + ", Session " + session.getId());
        
        try {
            int uid = Integer.parseInt(userId);
            dao.NotificationDAO notifDAO = new dao.NotificationDAO();
            int unreadCount = notifDAO.getUnreadCount(uid);
            session.getBasicRemote().sendText("{\"unreadCount\": " + unreadCount + "}");
        } catch (Exception e) {
            System.err.println("Error sending initial unread count to user " + userId + ": " + e.getMessage());
        }
    }

    @OnMessage
    public void onMessage(String message, Session session, @PathParam("userId") String userId) {
        // Not typically receiving messages from client in this scenario
        System.out.println("Message from User " + userId + ": " + message);
    }

    @OnClose
    public void onClose(Session session, @PathParam("userId") String userId) {
        Set<Session> sessions = userSessions.get(userId);
        if (sessions != null) {
            sessions.remove(session);
            if (sessions.isEmpty()) {
                userSessions.remove(userId);
            }
        }
        System.out.println("WebSocket Closed: User " + userId + ", Session " + session.getId());
    }

    @OnError
    public void onError(Session session, Throwable throwable, @PathParam("userId") String userId) {
        System.err.println("WebSocket Error for User " + userId + ": " + throwable.getMessage());
    }

    /**
     * Sends a message to a specific user across all their active sessions.
     */
    public static void sendNotification(String userId, String message) {
        Set<Session> sessions = userSessions.get(userId);
        if (sessions != null) {
            for (Session session : sessions) {
                if (session.isOpen()) {
                    try {
                        session.getBasicRemote().sendText(message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
