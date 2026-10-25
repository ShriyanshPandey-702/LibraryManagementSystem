package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.NotificationDAO;
import model.Notification;
import model.Student;

@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        int userId = 0;
        String role = "";

        if (session != null && session.getAttribute("adminUser") != null) {
            userId = 1;
            role = "admin";
            // Check for admin alerts on pending requests, incidents, and waitlists
            notificationDAO.generateAdminAlerts();
        } else if (session != null && session.getAttribute("studentUser") != null) {
            Student s = (Student) session.getAttribute("studentUser");
            userId = s.getId();
            role = "student";
            // Check for due date reminders
            notificationDAO.generateAutomatedReminders();
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Unauthorized\"}");
            return;
        }

        int unreadCount = notificationDAO.getUnreadCount(userId, role);
        List<Notification> list = notificationDAO.getUserNotifications(userId, role, 10);

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        StringBuilder json = new StringBuilder();
        json.append("{\"unreadCount\": ").append(unreadCount).append(", \"notifications\": [");

        for (int i = 0; i < list.size(); i++) {
            Notification n = list.get(i);
            if (i > 0) json.append(",");
            json.append("{")
                .append("\"id\": ").append(n.getId()).append(",")
                .append("\"title\": \"").append(escapeJson(n.getTitle())).append("\",")
                .append("\"message\": \"").append(escapeJson(n.getMessage())).append("\",")
                .append("\"type\": \"").append(escapeJson(n.getType())).append("\",")
                .append("\"link\": \"").append(escapeJson(n.getLink() != null ? n.getLink() : "")).append("\",")
                .append("\"isRead\": ").append(n.isRead()).append(",")
                .append("\"createdAt\": \"").append(n.getCreatedAt() != null ? n.getCreatedAt().toString() : "").append("\"")
                .append("}");
        }
        json.append("]}");
        out.write(json.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        int userId = 0;
        String role = "";

        if (session != null && session.getAttribute("adminUser") != null) {
            userId = 1;
            role = "admin";
        } else if (session != null && session.getAttribute("studentUser") != null) {
            Student s = (Student) session.getAttribute("studentUser");
            userId = s.getId();
            role = "student";
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        if ("markAllRead".equalsIgnoreCase(action)) {
            notificationDAO.markAllAsRead(userId, role);
        } else if ("markRead".equalsIgnoreCase(action)) {
            try {
                int nid = Integer.parseInt(request.getParameter("id"));
                notificationDAO.markAsRead(nid, userId, role);
            } catch (Exception e) {}
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\": true}");
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
