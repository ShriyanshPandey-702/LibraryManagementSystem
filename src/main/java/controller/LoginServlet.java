package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.LoginDAO;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private final LoginDAO loginDAO = new LoginDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("1".equals(request.getParameter("reset"))) {
            request.setAttribute("successMessage", "Password reset successful. Please login.");
        }
        request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            if (loginDAO.validateAdmin(username, password)) {
                HttpSession session = request.getSession();
                session.setAttribute("adminUser", username);
                response.sendRedirect("DashboardServlet");
                return;
            }
            request.setAttribute("errorMessage", "Invalid username or password");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Database is unavailable. Please ensure MySQL server is running.");
        }
        request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
    }
}