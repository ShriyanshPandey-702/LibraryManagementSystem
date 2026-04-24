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

@WebServlet("/StudentProfileServlet")
public class StudentProfileServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        Student student = (Student) session.getAttribute("studentUser");
        // Refresh student data from DB
        Student updatedStudent = studentDAO.getStudentByEmail(student.getEmail());
        if (updatedStudent != null) {
            session.setAttribute("studentUser", updatedStudent);
        }

        request.getRequestDispatcher("jsp/student-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        Student student = (Student) session.getAttribute("studentUser");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword != null && !newPassword.isEmpty()) {
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Passwords do not match");
                request.getRequestDispatcher("jsp/student-profile.jsp").forward(request, response);
                return;
            }

            if (studentDAO.updateStudentPassword(student.getEmail(), newPassword)) {
                request.setAttribute("successMessage", "Password updated successfully");
            } else {
                request.setAttribute("errorMessage", "Unable to update password");
            }
        }

        request.getRequestDispatcher("jsp/student-profile.jsp").forward(request, response);
    }
}
