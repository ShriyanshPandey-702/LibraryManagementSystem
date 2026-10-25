package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.LostDamagedDAO;

@WebServlet("/AdminLostDamagedServlet")
public class AdminLostDamagedServlet extends HttpServlet {

    private final LostDamagedDAO lostDamagedDAO = new LostDamagedDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isEmpty()) statusFilter = "ALL";

        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("reports", lostDamagedDAO.getAllReports(statusFilter));
        request.getRequestDispatcher("jsp/admin-lost-damaged.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        try {
            int reportId = Integer.parseInt(request.getParameter("reportId"));
            String status = request.getParameter("status");
            String adminNotes = request.getParameter("adminNotes");
            double fineAmount = 0.0;
            String fineParam = request.getParameter("fineAmount");
            if (fineParam != null && !fineParam.trim().isEmpty()) {
                fineAmount = Double.parseDouble(fineParam.trim());
            }

            boolean ok = lostDamagedDAO.resolveReport(reportId, status, adminNotes, fineAmount);
            if (ok) {
                session.setAttribute("flashSuccess", "Report updated successfully.");
            } else {
                session.setAttribute("flashError", "Failed to update report.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Invalid report update parameters.");
        }

        response.sendRedirect("AdminLostDamagedServlet");
    }
}
