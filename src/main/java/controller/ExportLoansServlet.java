package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.IssueDAO;
import model.IssueRecord;

@WebServlet("/ExportLoansServlet")
public class ExportLoansServlet extends HttpServlet {

    private final IssueDAO issueDAO = new IssueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        List<IssueRecord> loans = issueDAO.getAllIssues();

        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"circulation-loans-export.csv\"");

        PrintWriter writer = response.getWriter();
        writer.println("Loan ID,Book ID,Book Title,Student Name,Student Contact,Issue Date,Due Date,Return Date,Fine (INR),Status,Fine Paid");

        for (IssueRecord l : loans) {
            writer.printf("%d,%d,\"%s\",\"%s\",\"%s\",%s,%s,%s,%.2f,%s,%s%n",
                l.getIssueId(),
                l.getBookId(),
                escapeCsv(l.getBookTitle()),
                escapeCsv(l.getStudentName()),
                escapeCsv(l.getStudentContact()),
                l.getIssueDate() != null ? l.getIssueDate().toString() : "",
                l.getDueDate() != null ? l.getDueDate().toString() : "",
                l.getReturnDate() != null ? l.getReturnDate().toString() : "",
                l.getFine(),
                l.getStatus(),
                l.isFinePaid() ? "Paid" : "Unpaid"
            );
        }
        writer.flush();
    }

    private String escapeCsv(String str) {
        if (str == null) return "";
        return str.replace("\"", "\"\"");
    }
}
