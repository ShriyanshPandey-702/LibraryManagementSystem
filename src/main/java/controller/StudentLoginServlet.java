package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.StudentDAO;
import model.Student;

@WebServlet("/StudentLoginServlet")
public class StudentLoginServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession existingSession = request.getSession(false);
        if (existingSession != null && existingSession.getAttribute("adminUser") != null) {
            response.sendRedirect("DashboardServlet");
            return;
        }
        if ("1".equals(request.getParameter("reset"))) {
            request.setAttribute("successMessage", "Password reset successful. Please login.");
        }
        if ("1".equals(request.getParameter("registered"))) {
            request.setAttribute("successMessage", "Registration successful! Please login.");
        }
        request.getRequestDispatcher("jsp/student-login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession currentSession = request.getSession(false);
        if (currentSession != null && currentSession.getAttribute("adminUser") != null) {
            response.sendRedirect("DashboardServlet");
            return;
        }

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email != null) email = email.trim().toLowerCase();

        if (studentDAO.validateStudent(email, password)) {
            HttpSession session = request.getSession();
            model.Student student = studentDAO.getStudentByEmail(email);
            if (student != null) {
                session.setAttribute("studentUser", student);
                session.setAttribute("studentId", student.getId());
                session.setAttribute("studentName", student.getName());
            }
            response.sendRedirect("StudentDashboardServlet");
            return;
        }

        request.setAttribute("errorMessage", "Invalid email or password");
        request.getRequestDispatcher("jsp/student-login.jsp").forward(request, response);
    }
}
