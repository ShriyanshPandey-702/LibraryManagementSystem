package controller;

import dao.StudentDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/SettingsServlet")
public class SettingsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }
        StudentDAO studentDAO = new StudentDAO();
        request.setAttribute("students", studentDAO.getAllStudents());
        request.setAttribute("totalStudents", studentDAO.countStudents());
        request.getRequestDispatcher("jsp/settings.jsp").forward(request, response);
    }
}
