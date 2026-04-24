package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.LoginDAO;
import dao.StudentDAO;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    private final LoginDAO loginDAO = new LoginDAO();
    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userType = request.getParameter("userType");
        if (userType == null || (!"admin".equalsIgnoreCase(userType) && !"student".equalsIgnoreCase(userType))) {
            userType = "admin";
        }

        request.setAttribute("userType", userType.toLowerCase());
        request.getRequestDispatcher("jsp/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userType = request.getParameter("userType");
        String identifier = request.getParameter("identifier");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (userType == null || (!"admin".equalsIgnoreCase(userType) && !"student".equalsIgnoreCase(userType))) {
            request.setAttribute("errorMessage", "Invalid account type.");
            request.setAttribute("userType", "admin");
            request.getRequestDispatcher("jsp/forgot-password.jsp").forward(request, response);
            return;
        }

        userType = userType.toLowerCase();

        if (identifier == null || identifier.trim().isEmpty() || newPassword == null || newPassword.trim().isEmpty()) {
            request.setAttribute("errorMessage", "All fields are required.");
            request.setAttribute("userType", userType);
            request.getRequestDispatcher("jsp/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match.");
            request.setAttribute("userType", userType);
            request.getRequestDispatcher("jsp/forgot-password.jsp").forward(request, response);
            return;
        }

        boolean updated;
        if ("admin".equals(userType)) {
            if (!loginDAO.adminExists(identifier)) {
                request.setAttribute("errorMessage", "Admin username not found.");
                request.setAttribute("userType", userType);
                request.getRequestDispatcher("jsp/forgot-password.jsp").forward(request, response);
                return;
            }
            updated = loginDAO.updateAdminPassword(identifier, newPassword);
        } else {
            if (!studentDAO.studentExistsByEmail(identifier)) {
                request.setAttribute("errorMessage", "Student email not found.");
                request.setAttribute("userType", userType);
                request.getRequestDispatcher("jsp/forgot-password.jsp").forward(request, response);
                return;
            }
            updated = studentDAO.updateStudentPassword(identifier, newPassword);
        }

        if (updated) {
            if ("admin".equals(userType)) {
                response.sendRedirect("LoginServlet?reset=1");
            } else {
                response.sendRedirect("StudentLoginServlet?reset=1");
            }
            return;
        }

        request.setAttribute("errorMessage", "Unable to reset password. Please try again.");
        request.setAttribute("userType", userType);
        request.getRequestDispatcher("jsp/forgot-password.jsp").forward(request, response);
    }
}
