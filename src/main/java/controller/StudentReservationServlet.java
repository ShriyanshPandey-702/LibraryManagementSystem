package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.ReservationDAO;
import model.Student;

@WebServlet({"/StudentReservationsServlet", "/StudentReservationServlet"})
public class StudentReservationServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        Student student = (Student) session.getAttribute("studentUser");
        request.setAttribute("reservations", reservationDAO.getStudentReservations(student.getId()));
        request.getRequestDispatcher("jsp/student-reservations.jsp").forward(request, response);
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
        String action = request.getParameter("action");

        if ("reserve".equalsIgnoreCase(action)) {
            try {
                int bookId = Integer.parseInt(request.getParameter("bookId"));
                ReservationDAO.ReservationResult res = reservationDAO.reserveBook(bookId, student.getId());
                if (res.isSuccess()) {
                    session.setAttribute("flashSuccess", res.getMessage());
                } else {
                    session.setAttribute("flashError", res.getMessage());
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("flashError", "Invalid reservation request.");
            }
            response.sendRedirect("StudentReservationsServlet");
            return;
        } else if ("cancel".equalsIgnoreCase(action)) {
            try {
                int reservationId = Integer.parseInt(request.getParameter("reservationId"));
                boolean ok = reservationDAO.cancelReservation(reservationId, student.getId());
                if (ok) {
                    session.setAttribute("flashSuccess", "Reservation cancelled.");
                } else {
                    session.setAttribute("flashError", "Unable to cancel reservation.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("flashError", "Invalid cancel request.");
            }
            response.sendRedirect("StudentReservationsServlet");
            return;
        }

        response.sendRedirect("StudentReservationsServlet");
    }
}
