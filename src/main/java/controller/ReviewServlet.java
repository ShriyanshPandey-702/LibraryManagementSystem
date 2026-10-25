package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.ReviewDAO;
import model.Student;

@WebServlet("/ReviewServlet")
public class ReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String action = request.getParameter("action");
        if (action == null) action = "add";

        String bookIdParam = request.getParameter("bookId");
        int bookId = 0;
        try {
            bookId = Integer.parseInt(bookIdParam);
        } catch (Exception e) {}

        if ("moderate".equalsIgnoreCase(action)) {
            // Admin only
            if (session == null || session.getAttribute("adminUser") == null) {
                response.sendRedirect("LoginServlet");
                return;
            }
            try {
                int reviewId = Integer.parseInt(request.getParameter("reviewId"));
                boolean hide = Boolean.parseBoolean(request.getParameter("hide"));
                reviewDAO.setHidden(reviewId, hide);
                request.getSession().setAttribute("flashSuccess", "Review visibility updated.");
            } catch (Exception e) {
                e.printStackTrace();
            }
            response.sendRedirect("ViewBooksServlet");
            return;
        }

        // Student operations
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        Student student = (Student) session.getAttribute("studentUser");

        if ("delete".equalsIgnoreCase(action)) {
            try {
                int reviewId = Integer.parseInt(request.getParameter("reviewId"));
                reviewDAO.deleteReview(reviewId, student.getId());
                request.getSession().setAttribute("flashSuccess", "Your review has been deleted.");
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            // Add or update review
            try {
                int rating = Integer.parseInt(request.getParameter("rating"));
                String reviewText = request.getParameter("reviewText");

                // Eligibility check: student must have borrowed the book
                if (!reviewDAO.hasStudentBorrowedBook(bookId, student.getId())) {
                    request.getSession().setAttribute("flashError", "You can only review books that you have borrowed.");
                } else {
                    boolean ok = reviewDAO.addOrUpdateReview(bookId, student.getId(), rating, reviewText);
                    if (ok) {
                        request.getSession().setAttribute("flashSuccess", "Thank you! Your rating and review have been saved.");
                    } else {
                        request.getSession().setAttribute("flashError", "Failed to save review.");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.getSession().setAttribute("flashError", "Invalid review data.");
            }
        }

        response.sendRedirect("StudentViewBooksServlet?bookId=" + bookId);
    }
}
