<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Student" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    List<Student> students = (List<Student>) request.getAttribute("students");
    Object totalStudents = request.getAttribute("totalStudents");
    int count = students != null ? students.size() : 0;
    dao.SettingsDAO settingsDAO = new dao.SettingsDAO();
    int configuredMaxBooks = settingsDAO.getIntSetting("max_books_per_student", 5);
    int configuredRenewalDays = settingsDAO.getIntSetting("renewal_days", 14);
    double configuredDailyFine = settingsDAO.getDoubleSetting("fine_per_day", 10.0);
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">System &amp; Students</h1>
            <p class="page-subtitle">Circulation business rules, security configurations, and authorized student borrowers.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/FineSettingsServlet" class="btn-lib-primary">
                <i class="fas fa-sliders me-1"></i> Edit Library Policies
            </a>
        </div>
    </header>

    <!-- Operational Policies Panel -->
    <div class="panel mb-4">
        <div class="panel-header">
            <h2 class="panel-title">Institutional Circulation Rules</h2>
            <span class="badge-status badge-success">Enforced Server-Side</span>
        </div>
        <div class="panel-body">
            <div class="row g-4">
                <div class="col-md-3">
                    <div class="p-3 border rounded-1 bg-light">
                        <div class="text-muted small text-uppercase fw-bold mb-1" style="font-size: 0.72rem;">Borrowing Quota</div>
                        <div class="h5 fw-bold mb-1"><%= configuredMaxBooks %> Books Max</div>
                        <div class="text-muted small">Configurable per-student borrowing quota across all active loans.</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="p-3 border rounded-1 bg-light">
                        <div class="text-muted small text-uppercase fw-bold mb-1" style="font-size: 0.72rem;">Loan Period</div>
                        <div class="h5 fw-bold mb-1">7 Days</div>
                        <div class="text-muted small">Default checkout duration calculated from date of issue.</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="p-3 border rounded-1 bg-light">
                        <div class="text-muted small text-uppercase fw-bold mb-1" style="font-size: 0.72rem;">Renewal Extension</div>
                        <div class="h5 fw-bold mb-1">+<%= configuredRenewalDays %> Days</div>
                        <div class="text-muted small">Configurable extension per renewal; blocked if overdue fines exist.</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="p-3 border rounded-1 bg-light">
                        <div class="text-muted small text-uppercase fw-bold mb-1" style="font-size: 0.72rem;">Security &amp; Hashing</div>
                        <div class="h5 fw-bold mb-1">BCrypt Active</div>
                        <div class="text-muted small">Cryptographic hash on all credentials; SQL injection protected.</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Registered Students Panel -->
    <div class="panel">
        <div class="panel-header">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Registered Student Directory</h2>
                <span class="badge-status badge-neutral"><%= count %> <%= count == 1 ? "Member" : "Members" %></span>
            </div>
            <span class="text-muted small">Active borrowers eligible for book issuance</span>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0">
                <thead>
                    <tr>
                        <th style="width: 70px;">ID</th>
                        <th>Student Name</th>
                        <th>Email Address</th>
                        <th>Mobile</th>
                        <th>Course</th>
                        <th>Academic Year</th>
                        <th>Section</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (students != null && !students.isEmpty()) {
                            for (Student student : students) {
                    %>
                    <tr>
                        <td class="text-muted small">#<%= student.getId() %></td>
                        <td>
                            <strong class="text-dark"><%= student.getName() %></strong>
                        </td>
                        <td class="text-secondary"><%= student.getEmail() %></td>
                        <td class="text-muted small"><%= student.getMobile() != null && !student.getMobile().isEmpty() ? student.getMobile() : "—" %></td>
                        <td><%= student.getCourse() != null && !student.getCourse().isEmpty() ? student.getCourse() : "—" %></td>
                        <td>
                            <span class="badge-status badge-neutral"><%= student.getYear() != null && !student.getYear().isEmpty() ? student.getYear() : "N/A" %></span>
                        </td>
                        <td><%= student.getSection() != null && !student.getSection().isEmpty() ? student.getSection() : "—" %></td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fas fa-user-graduate"></i>
                                </div>
                                <h3 class="empty-state-title">No students registered</h3>
                                <p class="empty-state-text">
                                    Students can create an account through the student portal registration page.
                                </p>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

</div><!-- /.page-content -->

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
