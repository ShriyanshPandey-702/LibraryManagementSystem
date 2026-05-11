package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookDAO;

@WebServlet("/DeleteBookServlet")
public class DeleteBookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            if (session != null && session.getAttribute("studentUser") != null) {
                response.sendRedirect("StudentDashboardServlet");
            } else {
                response.sendRedirect("LoginServlet");
            }
            return;
        }

        String idParam = request.getParameter("id");

        try {
            int id = Integer.parseInt(idParam);
            bookDAO.deleteBook(id);
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("ViewBooksServlet");
    }
}