package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.StudentDAO;

@WebServlet("/StudentRegisterServlet")
public class StudentRegisterServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("adminUser") != null) {
            response.sendRedirect("DashboardServlet");
            return;
        }
        request.getRequestDispatcher("jsp/student-register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("adminUser") != null) {
            response.sendRedirect("DashboardServlet");
            return;
        }

        String name    = request.getParameter("name") != null ? request.getParameter("name").trim() : "";
        String email   = request.getParameter("email") != null ? request.getParameter("email").trim().toLowerCase() : "";
        String mobile  = request.getParameter("mobile") != null ? request.getParameter("mobile").trim() : "";
        String password = request.getParameter("password") != null ? request.getParameter("password") : "";
        String course  = request.getParameter("course") != null ? request.getParameter("course").trim() : "";
        String year    = request.getParameter("year") != null ? request.getParameter("year").trim() : "";
        String section = request.getParameter("section") != null ? request.getParameter("section").trim() : "";
        String address = request.getParameter("address") != null ? request.getParameter("address").trim() : "";

        if (name.isEmpty() || email.isEmpty() || password.isEmpty() || course.isEmpty() || year.isEmpty()) {
            request.setAttribute("errorMessage", "Please fill in all required fields.");
            request.getRequestDispatcher("jsp/student-register.jsp").forward(request, response);
            return;
        }

        boolean registered = studentDAO.registerStudent(name, email, mobile, password, course, year, section, address);

        if (registered) {
            response.sendRedirect("StudentLoginServlet?registered=1");
            return;
        }

        request.setAttribute("errorMessage", "Unable to register. Email may already exist.");
        request.getRequestDispatcher("jsp/student-register.jsp").forward(request, response);
    }
}
