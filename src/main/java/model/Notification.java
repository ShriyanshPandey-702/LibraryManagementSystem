package model;

import java.sql.Timestamp;

public class Notification {
    private int id;
    private int userId;
    private String userRole; // 'student' or 'admin'
    private String title;
    private String message;
    private String type;     // 'DUE_SOON', 'OVERDUE', 'RENEWAL', 'RESERVATION_READY', 'FINE', 'RETURN', 'GENERAL'
    private String link;
    private boolean read;
    private Timestamp createdAt;

    public Notification() {}

    public Notification(int userId, String userRole, String title, String message, String type, String link) {
        this.userId = userId;
        this.userRole = userRole;
        this.title = title;
        this.message = message;
        this.type = type;
        this.link = link;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
