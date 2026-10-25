package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.ReservationDAO;

@WebServlet("/AdminReservationsServlet")
public class AdminReservationsServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();

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
        request.setAttribute("reservations", reservationDAO.getAllReservations(statusFilter));
        request.getRequestDispatcher("jsp/admin-reservations.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        String action = request.getParameter("action");
        if ("expireCheck".equalsIgnoreCase(action)) {
            reservationDAO.expireOverduePickups();
            session.setAttribute("flashSuccess", "Overdue reservation pickups checked and expired.");
        }

        response.sendRedirect("AdminReservationsServlet");
    }
}
