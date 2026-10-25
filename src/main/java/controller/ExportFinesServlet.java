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

@WebServlet("/ExportFinesServlet")
public class ExportFinesServlet extends HttpServlet {

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
        response.setHeader("Content-Disposition", "attachment; filename=\"overdue-fines-ledger.csv\"");

        PrintWriter writer = response.getWriter();
        writer.println("Loan ID,Student Name,Contact,Book Title,Due Date,Return Date,Fine (INR),Settlement Status");

        for (IssueRecord l : loans) {
            if (l.getFine() > 0) {
                writer.printf("%d,\"%s\",\"%s\",\"%s\",%s,%s,%.2f,%s%n",
                    l.getIssueId(),
                    escapeCsv(l.getStudentName()),
                    escapeCsv(l.getStudentContact()),
                    escapeCsv(l.getBookTitle()),
                    l.getDueDate() != null ? l.getDueDate().toString() : "",
                    l.getReturnDate() != null ? l.getReturnDate().toString() : "",
                    l.getFine(),
                    l.isFinePaid() ? "Settled / Paid" : "Outstanding / Unpaid"
                );
            }
        }
        writer.flush();
    }

    private String escapeCsv(String str) {
        if (str == null) return "";
        return str.replace("\"", "\"\"");
    }
}
